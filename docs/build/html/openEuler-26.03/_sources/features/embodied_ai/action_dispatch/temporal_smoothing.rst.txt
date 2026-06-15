时间平滑
========

.. raw:: html

   <details>

相关源文件

以下文件用于生成此 wiki 页面的上下文：

-  `README.en.md <README.en.md>`__
-  `README.md <README.md>`__
-  `docs/architecture.md <docs/architecture.md>`__
-  `/image/architecture.png </image/architecture.png>`__
-  `docs/roadmap.md <docs/roadmap.md>`__
-  `scripts/build.sh <scripts/build.sh>`__
-  `src/README.md <src/README.md>`__
-  `src/action_dispatch/README.en.md <src/action_dispatch/README.en.md>`__
-  `src/action_dispatch/README.md <src/action_dispatch/README.md>`__
-  `src/action_dispatch/action_dispatch/init.py <src/action_dispatch/action_dispatch/__init__.py>`__
-  `src/action_dispatch/action_dispatch/temporal_smoother.py <src/action_dispatch/action_dispatch/temporal_smoother.py>`__
-  `src/action_dispatch/test/test_temporal_smoother.py <src/action_dispatch/test/test_temporal_smoother.py>`__

.. raw:: html

   </details>

本文档深入介绍 **TemporalSmoother** 算法，该算法对 Action Chunking 策略（如 ACT、Diffusion Policy）产生的动作块执行跨帧指数加权混合。时间平滑确保连续推理输出之间的平滑过渡，防止动作计划在执行中途更新时出现突然的运动不连续。

有关整体动作分发系统和队列管理的信息，请参阅 `动作分发器节点 <#8.1>`__。有关平滑后的动作如何通过话题或动作服务器执行的详细信息，请参阅 `话题与动作执行器 <#8.3>`__。

**来源**：`src/action_dispatch/README.en.md:1-447 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L1-L447>`__,
`src/action_dispatch/action_dispatch/temporal_smoother.py:1-322 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/temporal_smoother.py#L1-L322>`__

--------------

问题陈述：动作块重叠
--------------------

Action Chunking 策略每次推理输出 ``n`` 个动作序列（通常 ``n=100``）。然而，推理并非瞬间完成——当模型计算下一个动作块时，机器人继续执行前一个块中的动作。这产生了时间重叠问题：

::

   T1: First inference produces [a1, a2, a3, ..., a100]
       Robot begins executing: a1, a2, a3...
       
   T2: Inference starts (queue watermark triggered)
       Robot continues: a4, a5, a6...
       
   T3: Inference completes after robot executed 30 actions
       New chunk: [b1, b2, b3, ..., b100]
       Remaining old actions: [a31, a32, ..., a100]
       
   Problem: How to transition from old plan to new plan?

如果不进行平滑，有两个糟糕的选择：1. **丢弃新块**：继续执行过时的预测 → 模型预测变得无关 2. **立即替换**：从 ``a30`` 跳到 ``b31`` → 突然的运动不连续

时间平滑通过 **混合重叠区域** 使用指数加权来解决这个问题，既保持连续性又保持对新预测的响应性。

**来源**：`src/action_dispatch/README.en.md:212-221 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L212-L221>`__,
`src/action_dispatch/README.md:211-221 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.md#L211-L221>`__

--------------

算法概述
--------

时间平滑算法分三个阶段运行：

**阶段 1：时间对齐图**

.. mermaid::

   graph LR
       subgraph "T1: First Inference"
           A1["actions1[0:100]<br/>(100 actions)"]
       end
       
       subgraph "T2: Execution During Inference"
           E1["executed[0:30]<br/>(30 actions consumed)"]
           R1["remaining[30:100]<br/>(70 actions left)"]
       end
       
       subgraph "T3: Second Inference"
           A2["actions2[0:100]<br/>(100 new actions)"]
       end
       
       subgraph "T4: Alignment"
           Skip["actions2[0:30]<br/>(skip outdated)"]
           Relevant["actions2[30:100]<br/>(70 relevant new)"]
       end
       
       A1 --> E1
       A1 --> R1
       A2 --> Skip
       A2 --> Relevant
       
       R1 -.->|"overlap with"| Relevant

**阶段 2：指数加权混合**

.. mermaid::

   graph TB
       subgraph "Overlap Region Processing"
           Old["old_actions[30:100]<br/>(70 old remaining)"]
           New["new_actions[30:100]<br/>(70 new relevant)"]
           
           Old --> Blend["Exponential Weighted<br/>Blending Formula"]
           New --> Blend
           
           Blend --> Result["blended[30:100]<br/>(70 smoothed actions)"]
       end
       
       subgraph "Weight Calculation"
           Count["action_counts[i]<br/>(how many times seen)"]
           Weights["weights = exp(-coeff * k)"]
           Cumsum["cumsum(weights)"]
           
           Count --> Formula["blended[i] = <br/>(old[i] * cumsum[count-1] + <br/>new[i] * weights[count]) <br/>/ cumsum[count]"]
           Weights --> Formula
           Cumsum --> Formula
       end
       
       Formula -.-> Blend

**来源**：`src/action_dispatch/README.en.md:224-257 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L224-L257>`__,
`src/action_dispatch/action_dispatch/temporal_smoother.py:44-77 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/temporal_smoother.py#L44-L77>`__

--------------

核心组件
--------

时间平滑实现由 ``src/action_dispatch/action_dispatch/temporal_smoother.py`` 中的三个主要类组成：

类层次图
~~~~~~~~

.. mermaid::

   graph TB
       Config["TemporalSmootherConfig<br/>@dataclass"]
       Smoother["TemporalSmoother<br/>Core smoothing logic"]
       Manager["TemporalSmootherManager<br/>Convenience wrapper"]
       
       Config -->|"configures"| Smoother
       Smoother -->|"wrapped by"| Manager
       
       subgraph "TemporalSmootherConfig Fields"
           F1["enabled: bool = True"]
           F2["chunk_size: int = 100"]
           F3["temporal_ensemble_coeff: float = 0.01"]
           F4["device: Optional[str] = None"]
       end
       
       Config --- F1
       Config --- F2
       Config --- F3
       Config --- F4
       
       subgraph "TemporalSmoother State"
           S1["_smoothed_actions: Tensor"]
           S2["_action_counts: Tensor"]
           S3["_weights: Tensor"]
           S4["_weights_cumsum: Tensor"]
       end
       
       Smoother --- S1
       Smoother --- S2
       Smoother --- S3
       Smoother --- S4
       
       subgraph "Key Methods"
           M1["update(new_actions, actions_executed)"]
           M2["get_next_action()"]
           M3["peek_next_action()"]
           M4["reset()"]
       end
       
       Smoother --- M1
       Smoother --- M2
       Smoother --- M3
       Smoother --- M4

**来源**：
`src/action_dispatch/action_dispatch/temporal_smoother.py:19-42 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/temporal_smoother.py#L19-L42>`__,
`src/action_dispatch/action_dispatch/temporal_smoother.py:44-257 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/temporal_smoother.py#L44-L257>`__,
`src/action_dispatch/action_dispatch/temporal_smoother.py:259-322 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/temporal_smoother.py#L259-L322>`__

TemporalSmootherConfig
~~~~~~~~~~~~~~~~~~~~~~

定义在 `src/action_dispatch/action_dispatch/temporal_smoother.py:19-42 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/temporal_smoother.py#L19-L42>`__ 的配置数据类。


.. list-table::
   :header-rows: 1

   * - 字段
     - 类型
     - 默认值
     - 描述
   * - ``enabled``
     - ``bool``
     - ``True``
     - 启用平滑。如果 ``False``，仅作为 对齐的直通模式。
   * - ``c hunk_size``
     - ``int``
     - ``100``
     - 每块最大动作数。 用于权重预计算。
   * - ``tem poral_ensem ble_coeff``
     - ``float``
     - ``0.01``
     - 指数衰减系数。参见 `平滑系数效果 <#smoothi ng-coefficient-effects>`__。
   * - ``device``
     - ``Option al[str]``
     - ``None``
     - 张量操作设备 （``'cpu'``、``'cuda'``、 ``'npu:0'``）。 如果 ``None`` 则自动检测。

**来源**：
`src/action_dispatch/action_dispatch/temporal_smoother.py:19-42 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/temporal_smoother.py#L19-L42>`__

TemporalSmoother
~~~~~~~~~~~~~~~~

核心平滑实现位于
`src/action_dispatch/action_dispatch/temporal_smoother.py:44-257 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/temporal_smoother.py#L44-L257>`__。
维护内部状态：

-  ``_smoothed_actions``：当前平滑后的动作计划（形状：``[plan_length, action_dim]``）
-  ``_action_counts``：每个动作被混合的次数（形状：``[plan_length, 1]``）
-  ``_weights``：预计算的指数权重（形状：``[chunk_size]``）
-  ``_weights_cumsum``：权重的累加和（形状：``[chunk_size]``）

**关键方法**：


.. list-table::
   :header-rows: 1

   * - 方法
     - 签名
     - 用途
   * - ``update()``
     - ``update(new_ac tions, actions_executed_d uring_inference) -> int``
     - 核心平滑逻辑。 对齐并混合新块。
   * - ``ge t_next_action()``
     - ``get_ next_action() -> Tensor``
     - 弹出并返回计划中的 下一个动作。
   * - ``pee k_next_action()``
     - ``peek_next_actio n() -> Optional[Tensor]``
     - 返回下一个动作 但不移除它。
   * - ``reset()``
     - ``reset()``
     - 清除内部状态以 开始新回合。
   * - ``plan_length``
     - ``@prop erty plan_length -> int``
     - 返回当前计划中的 动作数量。

**来源**：
`src/action_dispatch/action_dispatch/temporal_smoother.py:44-257 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/temporal_smoother.py#L44-L257>`__

TemporalSmootherManager
~~~~~~~~~~~~~~~~~~~~~~~

便捷包装器位于
`src/action_dispatch/action_dispatch/temporal_smoother.py:259-322 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/temporal_smoother.py#L259-L322>`__，
提供运行时切换和统一接口。将所有操作委托给内部 ``TemporalSmoother`` 实例。

额外方法：- ``set_enabled(enabled: bool)``：运行时开启/关闭平滑

**来源**：
`src/action_dispatch/action_dispatch/temporal_smoother.py:259-322 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/temporal_smoother.py#L259-L322>`__

--------------

平滑公式
--------

指数加权混合公式在
`src/action_dispatch/action_dispatch/temporal_smoother.py:208-246 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/temporal_smoother.py#L208-L246>`__ 中实现：

.. code:: python

   # For each action i in the overlap region:
   blended[i] = (old[i] * cumsum[count[i]-1] + new[i] * weights[count[i]]) 
                / cumsum[count[i]]

其中：- ``old[i]``：前一个平滑计划中的第 i 个动作 - ``new[i]``：新推理结果中的第 i 个动作（对齐后）- ``count[i]``：动作 i 被混合的次数（从 1 开始）- ``weights[k] = exp(-temporal_ensemble_coeff * k)`` - ``cumsum[k]`` = 索引 k 之前的权重累加和

权重计算
~~~~~~~~

权重在初始化时预计算，位于
`src/action_dispatch/action_dispatch/temporal_smoother.py:86-92 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/temporal_smoother.py#L86-L92>`__：

.. code:: python

   coeff = self.config.temporal_ensemble_coeff
   chunk_size = self.config.chunk_size

   self._weights = torch.exp(-coeff * torch.arange(chunk_size, dtype=torch.float32))
   self._weights_cumsum = torch.cumsum(self._weights, dim=0)

**权重进展示例**\ （对于 ``coeff=0.01``，前 5 步）：

= ========= ========= ========================================
k weight[k] cumsum[k] 解释
= ========= ========= ========================================
0 1.000     1.000     第一次贡献（新动作）
1 0.990     1.990     第二次混合（旧权重累积）
2 0.980     2.970     第三次混合
3 0.970     3.940     第四次混合
4 0.961     4.901     第五次混合
= ========= ========= ========================================

随着 ``count[i]`` 增加，分母增长，给予累积旧值更多影响。这通过优先考虑已提交的动作来创造 **稳定性**。

**来源**：
`src/action_dispatch/action_dispatch/temporal_smoother.py:86-92 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/temporal_smoother.py#L86-L92>`__,
`src/action_dispatch/action_dispatch/temporal_smoother.py:208-246 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/temporal_smoother.py#L208-L246>`__,
`src/action_dispatch/README.en.md:311-322 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L311-L322>`__

--------------

时间对齐过程
------------

``update()`` 方法位于
`src/action_dispatch/action_dispatch/temporal_smoother.py:145-206 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/temporal_smoother.py#L145-L206>`__
处理时间对齐：

对齐流程图
~~~~~~~~~~

.. mermaid::

   flowchart TD
       Start["update(new_actions, actions_executed)"]
       
       ValidateInput["Validate input shape<br/>[temporal_smoother.py:168-173]"]
       
       CheckEmpty{"new_actions.shape[0] == 0?"}
       ReturnEarly["Return current plan_length"]
       
       ConvertTensor["Convert to tensor on device<br/>[temporal_smoother.py:175-179]"]
       
       Align["Slice alignment:<br/>relevant_new = new_actions[actions_executed:]<br/>[temporal_smoother.py:181]"]
       
       CheckState{"Is _smoothed_actions None<br/>or empty?"}
       
       InitializePlan["Initialize plan:<br/>_smoothed_actions = relevant_new<br/>_action_counts = ones(...)<br/>[temporal_smoother.py:183-189]"]
       
       CheckSmoothing{"config.enabled?"}
       
       ReplaceNoSmooth["Replace without smoothing:<br/>_smoothed_actions = relevant_new<br/>[temporal_smoother.py:190-196]"]
       
       ApplySmoothing["_apply_smoothing()<br/>[temporal_smoother.py:198-204]"]
       
       ReturnLength["Return plan_length"]
       
       Start --> ValidateInput
       ValidateInput --> CheckEmpty
       CheckEmpty -->|"Yes"| ReturnEarly
       CheckEmpty -->|"No"| ConvertTensor
       ConvertTensor --> Align
       Align --> CheckState
       CheckState -->|"Yes"| InitializePlan
       CheckState -->|"No"| CheckSmoothing
       CheckSmoothing -->|"No"| ReplaceNoSmooth
       CheckSmoothing -->|"Yes"| ApplySmoothing
       InitializePlan --> ReturnLength
       ReplaceNoSmooth --> ReturnLength
       ApplySmoothing --> ReturnLength

**来源**：
`src/action_dispatch/action_dispatch/temporal_smoother.py:145-206 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/temporal_smoother.py#L145-L206>`__

混合实现
~~~~~~~~

``_apply_smoothing()`` 方法位于
`src/action_dispatch/action_dispatch/temporal_smoother.py:208-246 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/temporal_smoother.py#L208-L246>`__
执行实际混合：

.. mermaid::

   flowchart TD
       Start["_apply_smoothing(old_actions, old_counts, new_actions, weights, weights_cumsum)"]
       
       CalcOverlap["overlap_len = min(old.shape[0], new.shape[0])<br/>[temporal_smoother.py:226]"]
       
       SliceRegions["old_overlap = old[:overlap_len]<br/>new_overlap = new[:overlap_len]<br/>new_tail = new[overlap_len:]<br/>[temporal_smoother.py:228-230]"]
       
       GetCounts["counts_for_update = old_counts[:overlap_len]<br/>[temporal_smoother.py:232]"]
       
       ComputeOldSum["old_sum = old_overlap * weights_cumsum[counts - 1]<br/>[temporal_smoother.py:234]"]
       
       ComputeNewTerm["new_term = new_overlap * weights[counts]<br/>[temporal_smoother.py:235]"]
       
       Blend["blended = (old_sum + new_term) / weights_cumsum[counts]<br/>[temporal_smoother.py:236]"]
       
       UpdateCounts["updated_counts = clamp(counts + 1, max=chunk_size)<br/>[temporal_smoother.py:238]"]
       
       Concat["smoothed_actions = cat([blended, new_tail])<br/>action_counts = cat([updated_counts, ones(...)])<br/>[temporal_smoother.py:240-244]"]
       
       Return["return (smoothed_actions, action_counts)"]
       
       Start --> CalcOverlap
       CalcOverlap --> SliceRegions
       SliceRegions --> GetCounts
       GetCounts --> ComputeOldSum
       ComputeOldSum --> ComputeNewTerm
       ComputeNewTerm --> Blend
       Blend --> UpdateCounts
       UpdateCounts --> Concat
       Concat --> Return

**来源**：
`src/action_dispatch/action_dispatch/temporal_smoother.py:208-246 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/temporal_smoother.py#L208-L246>`__

--------------

平滑系数效果
------------

``temporal_ensemble_coeff`` 参数控制指数衰减率。其值决定了稳定性（遵循已提交动作）和响应性（适应新预测）之间的平衡。


.. list-table::
   :header-rows: 1

   * - 系数值
     - 权重行为
     - 效果
     - 用例
   * - ``0.0``
     - 均匀（所有 k 的 ``weights[k] = 1.0``）
     - 新旧等权
     - 最大响应性，可能导致抖动
   * - ``0.01`` （默认）
     - 慢衰减（``weights[4] ≈ 0.96``）
     - 略微偏好旧动作
     - 平衡稳定性和响应性（ACT 论文默认值）
   * - ``0.1``
     - 快衰减（``weights[4] ≈ 0.67``）
     - 强烈偏好旧动作
     - 保守、稳定、较少反应性
   * - ``-0.01``
     - 指数增长
     - 偏好 **新** 动作
     - 高度反应性，可能导致不稳定

权重衰减可视化
~~~~~~~~~~~~~~

对于不同系数值，k=10 时的权重：


.. list-table::
   :header-rows: 1

   * - 系数
     - ``weights[10]``
     - 累加和
     - 解释
   * - ``0.0``
     - 1.000
     - 11.000
     - 新动作获得 1/11 = 9.1% 权重
   * - ``0.01``
     - 0.905
     - 9.517
     - 新动作获得 9.5% 权重
   * - ``0.05``
     - 0.607
     - 7.869
     - 新动作获得 7.7% 权重
   * - ``0.1``
     - 0.368
     - 6.321
     - 新动作获得 5.8% 权重

**来源**：`src/action_dispatch/README.en.md:323-331 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L323-L331>`__,
`src/action_dispatch/action_dispatch/temporal_smoother.py:26-31 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/temporal_smoother.py#L26-L31>`__

--------------

使用模式
--------

使用 TemporalSmoother 的基本用法
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

来自 `src/action_dispatch/test/test_temporal_smoother.py:51-63 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/test/test_temporal_smoother.py#L51-L63>`__ 的示例：

.. code:: python

   from action_dispatch import TemporalSmoother, TemporalSmootherConfig

   # Configure
   config = TemporalSmootherConfig(
       enabled=True,
       chunk_size=100,
       temporal_ensemble_coeff=0.01
   )
   smoother = TemporalSmoother(config)

   # First inference: 100 actions for 7-DOF robot
   actions1 = np.random.randn(100, 7)
   smoother.update(actions1, actions_executed=0)

   assert smoother.plan_length == 100

   # Execute actions
   for _ in range(30):
       action = smoother.get_next_action()  # shape: (7,)
       # Send action to robot...

   # Second inference (30 actions executed during inference)
   actions2 = np.random.randn(100, 7)
   smoother.update(actions2, actions_executed=30)

   # Plan now contains 70 blended + 30 new = 100 actions
   assert smoother.plan_length == 100

**来源**：
`src/action_dispatch/test/test_temporal_smoother.py:51-90 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/test/test_temporal_smoother.py#L51-L90>`__,
`src/action_dispatch/README.en.md:383-413 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L383-L413>`__

使用 TemporalSmootherManager
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

管理器提供运行时切换能力，位于
`src/action_dispatch/action_dispatch/temporal_smoother.py:259-322 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/temporal_smoother.py#L259-L322>`__：

.. code:: python

   from action_dispatch import TemporalSmootherManager

   manager = TemporalSmootherManager(
       enabled=True,
       chunk_size=100,
       temporal_ensemble_coeff=0.01
   )

   # Check status
   print(f"Smoothing enabled: {manager.is_enabled}")
   print(f"Plan length: {manager.plan_length}")

   # Runtime toggle
   manager.set_enabled(False)  # Disable smoothing
   manager.set_enabled(True)   # Re-enable smoothing

   # Use same interface as TemporalSmoother
   manager.update(actions, actions_executed=30)
   action = manager.get_next_action()

**来源**：`src/action_dispatch/README.en.md:415-426 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L415-L426>`__,
`src/action_dispatch/test/test_temporal_smoother.py:176-216 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/test/test_temporal_smoother.py#L176-L216>`__

禁用平滑（仅对齐）
~~~~~~~~~~~~~~~~~~

当平滑被禁用时，位于
`src/action_dispatch/test/test_temporal_smoother.py:66-90 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/test/test_temporal_smoother.py#L66-L90>`__，
平滑器仍执行时间对齐但替换计划而非混合：

.. code:: python

   config = TemporalSmootherConfig(enabled=False, chunk_size=10)
   smoother = TemporalSmoother(config)

   # First chunk
   actions1 = np.ones((10, 7))
   smoother.update(actions1, 0)

   # Execute 3 actions
   for _ in range(3):
       smoother.get_next_action()

   # Second chunk arrives after 3 more actions executed
   actions2 = np.zeros((10, 7))
   smoother.update(actions2, actions_executed=3)

   # Plan is replaced with aligned actions2[3:]
   # Result: 7 actions, all zeros (no blending with ones)
   for _ in range(7):
       action = smoother.get_next_action()
       np.testing.assert_array_almost_equal(action, np.zeros(7))

**来源**：
`src/action_dispatch/test/test_temporal_smoother.py:66-90 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/test/test_temporal_smoother.py#L66-L90>`__

--------------

与动作分发器的集成
------------------

``TemporalSmoother`` 集成到 ``ActionDispatcherNode``
（参见 `动作分发器节点 <#8.1>`__）中，如下所示：

.. mermaid::

   graph TB
       subgraph "ActionDispatcherNode"
           Client["Action Client<br/>(DispatchInfer)"]
           Queue["Action Queue<br/>(FIFO buffer)"]
           Smoother["TemporalSmoother<br/>(Optional)"]
           Executor["TopicExecutor<br/>(100Hz publish)"]
       end
       
       subgraph "Inference Service"
           InfServer["lerobot_policy_node<br/>Action Server"]
       end
       
       subgraph "Control Loop State"
           QueueLen["queue_length at<br/>inference start"]
           Executed["actions_executed =<br/>queue_len_start - queue_len_now"]
       end
       
       Client -->|"Send goal when<br/>queue < watermark"| InfServer
       InfServer -->|"Return action chunk<br/>(VariantsList)"| Client
       
       Client -->|"Decode to tensor"| Smoother
       QueueLen --> Executed
       Executed -->|"actions_executed"| Smoother
       
       Smoother -->|"Smoothed actions"| Queue
       Queue -->|"Pop at 100Hz"| Executor
       
       Executor -->|"/joint_commands"| Hardware["ros2_control"]

动作分发器：1. 在推理开始时记录队列长度 2. 计算 ``actions_executed = queue_len_start - current_queue_len`` 3. 将 ``(new_chunk, actions_executed)`` 传递给平滑器 4. 将平滑后的动作入队以执行

**来源**：`src/action_dispatch/README.en.md:84-130 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L84-L130>`__,
`README.md:36-38 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L36-L38>`__

--------------

启动文件中的配置参数
--------------------

时间平滑参数可以通过 ROS 2 参数配置：


.. list-table::
   :header-rows: 1

   * - 参数
     - 类型
     - 默认值
     - 描述
   * - ``temporal_s moothing_enabled``
     - ``bool``
     - ``false``
     - 启用/禁用平滑
   * - ``tempora l_ensemble_coeff``
     - ``double``
     - ``0.01``
     - 指数衰减系数
   * - ``chunk_size``
     - ``int``
     - ``100``
     - 每块最大动作数
   * - `` smoothing_device``
     - ``string``
     - ``''``
     - 计算设备 （空 = 自动检测）

来自 `src/action_dispatch/README.en.md:186-209 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L186-L209>`__ 的启动配置示例：

.. code:: python

   from launch import LaunchDescription
   from launch_ros.actions import Node

   def generate_launch_description():
       return LaunchDescription([
           Node(
               package='action_dispatch',
               executable='action_dispatcher_node',
               name='action_dispatcher',
               parameters=[{
                   'temporal_smoothing_enabled': True,
                   'temporal_ensemble_coeff': 0.01,
                   'chunk_size': 100,
                   'smoothing_device': 'cuda:0',  # or 'cpu', 'npu:0'
               }]
           )
       ])

**来源**：`src/action_dispatch/README.en.md:172-209 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L172-L209>`__

--------------

运行时服务
----------

动作分发器提供用于运行时控制的 ROS 2 服务
（在 `动作分发器节点 <#8.1>`__ 中记录）：


.. list-table::
   :header-rows: 1

   * - 服务
     - 类型
     - 效果
   * - ``~/toggle_smoothing``
     - ``std_s rvs/srv/Empty``
     - 切换平滑 启用/禁用状态
   * - ``~/reset``
     - ``std_s rvs/srv/Empty``
     - 重置平滑器状态 （清除计划）

.. code:: bash

   # Toggle smoothing on/off
   ros2 service call /action_dispatcher/toggle_smoothing std_srvs/srv/Empty

   # Reset smoother state
   ros2 service call /action_dispatcher/reset std_srvs/srv/Empty

**来源**：`src/action_dispatch/README.en.md:335-341 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L335-L341>`__,
`src/action_dispatch/README.md:326-334 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.md#L326-L334>`__

--------------

测试
----

全面的测试位于
`src/action_dispatch/test/test_temporal_smoother.py:1-247 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/test/test_temporal_smoother.py#L1-L247>`__。关键测试场景：


.. list-table::
   :header-rows: 1

   * - 测试类
     - 覆盖范围
   * - ``TestTemporalSmootherConfig``
     - 配置验证、参数默认值
   * - ``TestTemporalSmoother``
     - 基本更新/获取、禁用平滑、 跨帧平滑、张量输入、重置
   * - ``TestTemporalSmootherManager``
     - 管理器接口、运行时切换、 peek 操作
   * - ``TestSmoothingFormula``
     - 权重计算、系数效果、累加和

验证跨帧平滑的示例测试位于
`src/action_dispatch/test/test_temporal_smoother.py:91-118 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/test/test_temporal_smoother.py#L91-L118>`__：

.. code:: python

   def test_cross_frame_smoothing(self):
       config = TemporalSmootherConfig(enabled=True, chunk_size=10, temporal_ensemble_coeff=0.01)
       smoother = TemporalSmoother(config)
       
       # First inference: actions of value 1.0
       actions1 = np.ones((10, 7)) * 1.0
       smoother.update(actions1, 0)
       
       for _ in range(3):
           smoother.get_next_action()
       
       # Second inference: actions of value 2.0
       actions2 = np.ones((10, 7)) * 2.0
       smoother.update(actions2, actions_executed=2)
       
       # First action should be blended (not exactly 1.0 or 2.0)
       first_action = smoother.peek_next_action()
       assert not np.allclose(first_action.numpy(), np.ones(7) * 1.0)
       assert not np.allclose(first_action.numpy(), np.ones(7) * 2.0)

运行测试：

.. code:: bash

   cd src/action_dispatch
   python -m pytest test/test_temporal_smoother.py -v

**来源**：
`src/action_dispatch/test/test_temporal_smoother.py:1-247 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/test/test_temporal_smoother.py#L1-L247>`__
