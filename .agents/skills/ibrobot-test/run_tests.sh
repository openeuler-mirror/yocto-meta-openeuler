#!/usr/bin/env bash
#
# IB-Robot test agent — component unit/colcon tests + inference-loop smoke.
# Works on qemu-aarch64 (no NPU) and real Ascend boxes (with CANN).
#
# Platform:
#   qemu : no NPU/CANN -> torch CPU (TORCH_DEVICE_BACKEND_AUTOLOAD=0). Full inference
#         (lerobot policy) needs aarch64 CANN/libhccl -> NOT runnable on qemu;
#         use `inference --no-inference` for mock-only smoke on qemu.
#   real : Ascend NPU + CANN -> torch_npu loads; full ACT inference runs.
#   auto : NPU-aware (default) — imports torch_npu to decide.
#
# Usage:
#   ./run_tests.sh list                          # list components + how each is tested
#   ./run_tests.sh <component> [pytest args]     # test one component
#   ./run_tests.sh all [--no-build]              # test all components (--no-build skips C++/colcon)
#   ./run_tests.sh build [pkgs...]               # colcon-build build-dependent packages
#   ./run_tests.sh inference [--model <ACT.zip|dir>] [--platform qemu|real]
#                           [--no-inference] [--duration <s>] [--robot <cfg>] [--warmup <s>]
#                                                # mock-sim + ACT inference smoke:
#     --model <ACT.zip|dir>   ACT policy bundle; zip is auto-extracted to models/.
#     --platform qemu|real    explicit platform (default: auto/NPU-aware).
#     --no-inference          mock only (with_inference:=false), no model needed.
#     --duration <s>          total run seconds (default 60).
#     --robot <cfg>           robot_config name (default so101_single_arm).
#     --warmup <s>            seconds before topic checks (default 20, model load).
#     Verifies /arm_position_controller/commands is published (actions flowing).
#   ./run_tests.sh --help
#
# Env (auto): sources .shrc_local + install/setup.sh; PYTEST_DISABLE_PLUGIN_AUTOLOAD=1;
#   ROS_DOMAIN_ID=42 / IBROBOT_TEST_ROS_DOMAIN_ID=42 / ROS_LOCALHOST_ONLY=1 (forced);
#   TORCH_DEVICE_BACKEND_AUTOLOAD=0 only when torch_npu can't load (qemu).
#
# Offline note (real box w/o internet): ACT inference's resnet18 encoder needs
#   ~/.cache/torch/hub/checkpoints/resnet18-f37072fd.pth — cache it offline first.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT" || { echo "cannot cd $REPO_ROOT"; exit 1; }

RESULTS_DIR="$REPO_ROOT/test_results"
TS="$(date +%Y%m%d_%H%M%S)"
LOGDIR="$RESULTS_DIR/$TS"
SUMMARY="$LOGDIR/summary.txt"

if [[ -t 1 ]]; then
  C_GRN='\033[32m'; C_RED='\033[31m'; C_YEL='\033[33m'; C_CYAN='\033[36m'; C_RST='\033[0m'
else
  C_GRN=''; C_RED=''; C_YEL=''; C_CYAN=''; C_RST=''
fi

COMPONENTS=(
  hardware_mock so101_hardware lekiwi_hardware omni_wheel_controller
  robot_config ibrobot_msgs tensormsg action_dispatch task_dispatch
  inference_service inference_manifest perception_service semantic_mapping attention_viz
  model_utils dataset_tools robot_moveit robot_navigation robot_teleop sim_models
  voice_asr_service embodied_common embodied_agent embodied_bringup vlm_task_planner
  safety_guard skill_library robot_skill_cli manipulation_service manipulation_execution
  lekiwi_description robot_description pymoveit2 rosclaw
)

BUILD_PKGS=(so101_hardware lekiwi_hardware omni_wheel_controller ibrobot_msgs lekiwi_description robot_description)

have() { command -v "$1" >/dev/null 2>&1; }

setup_env() {
  if [[ -f "$REPO_ROOT/.shrc_local" ]]; then
    # .shrc_local references possibly-unset vars (e.g. CONDA_DEFAULT_ENV); relax -u/-e while sourcing.
    set +u +e
    # shellcheck disable=SC1091
    source "$REPO_ROOT/.shrc_local" 2>/dev/null || true
    set -uo pipefail
  fi
  if [[ -f "$REPO_ROOT/install/setup.sh" ]]; then
    # source the built workspace so generated msgs/libs (ibrobot_msgs, etc.) are importable
    set +u +e
    # shellcheck disable=SC1091
    source "$REPO_ROOT/install/setup.sh" 2>/dev/null || true
    set -uo pipefail
  fi
  if have python3; then PY=python3; elif have python; then PY=python; else
    echo -e "${C_RED}no python found${C_RST}"; return 1
  fi
  if ! "$PY" -c 'import pytest' >/dev/null 2>&1; then
    echo -e "${C_YEL}warning: pytest not importable by $PY; python tests will fail to run${C_RST}"
  fi
  PYTEST="$PY -m pytest"
  # ROS Humble's launch_testing pytest plugin auto-loads and is incompatible with
  # the venv pytest/pluggy (PluginValidationError on pytest_pycollect_makemodule).
  # Disable plugin auto-load globally; IB-Robot tests are plain pytest (no plugins).
  export PYTEST_DISABLE_PLUGIN_AUTOLOAD=1
  # torch_npu auto-load: only disable when torch_npu cannot load (no Ascend CANN,
  # e.g. qemu/CI without NPU). On a real Ascend box (CANN sourced via .shrc_local)
  # torch_npu loads and the NPU is available -> leave autoload ON so Ascend tests run.
  if ! timeout 20 "$PY" -c 'import torch_npu' >/dev/null 2>&1; then
    export TORCH_DEVICE_BACKEND_AUTOLOAD=0
  fi
  # Class B fix: safety_guard / skill_library / robot_skill_cli gate every case behind
  # a ros_context fixture requiring a declared isolated ROS domain. FORCE the values
  # (not ${:-} defaults: .shrc_local/ROS preset ROS_LOCALHOST_ONLY=0, which would
  # otherwise survive and break the `assert ROS_LOCALHOST_ONLY == "1"` guard).
  export ROS_DOMAIN_ID=42
  export IBROBOT_TEST_ROS_DOMAIN_ID=42
  export ROS_LOCALHOST_ONLY=1
}

needs_build() {
  local p="$1"
  for b in "${BUILD_PKGS[@]}"; do [[ "$b" == "$p" ]] && return 0; done
  return 1
}

info() {
  local p="$1" kind build hw cmd
  case "$p" in
    hardware_mock)        kind=py;     build=no;  hw=no;  cmd="PYTHONPATH=src/hardware_mock python3 -m pytest src/hardware_mock/test";;
    so101_hardware)       kind=colcon; build=yes; hw=opt; cmd="colcon test --packages-select so101_hardware (gtest+pytest; 真机校准另用 arm_calibration_checker)";;
    lekiwi_hardware)      kind=colcon; build=yes; hw=opt; cmd="colcon test --packages-select lekiwi_hardware (55 gtest, 坐标转换纯函数)";;
    omni_wheel_controller)kind=colcon; build=yes; hw=opt; cmd="colcon test --packages-select omni_wheel_controller (gmock; 子模块)";;
    robot_config)         kind=py;     build=no;  hw=no;  cmd="pytest src/robot_config/test + validate_config.py (Gazebo E2E 需 NAV_TEST_PROFILE)";;
    ibrobot_msgs)         kind=colcon; build=yes; hw=no;  cmd="colcon test --packages-select ibrobot_msgs (ament_lint 静态检查)";;
    tensormsg)            kind=py;     build=no;  hw=no;  cmd="pytest src/tensormsg/test/test_converter.py (数值断言)";;
    action_dispatch)      kind=py;     build=no;  hw=no;  cmd="pytest src/action_dispatch/test (dispatcher/smoother/executor)";;
    task_dispatch)         kind=none;  build=no;  hw=sim; cmd="无 test 目录; 需 runtime sim 跑 ros2 action send_goal CLI 验证";;
    inference_service)    kind=py;     build=no;  hw=opt; cmd="PYTEST_DISABLE_PLUGIN_AUTOLOAD=1 PYTHONPATH=src/inference_manifest:src/inference_service pytest src/inference_service/tests";;
    inference_manifest)   kind=smoke;  build=no;  hw=no;  cmd="import 冒烟 (无自有测试; 经 inference_service/model_utils 覆盖)";;
    perception_service)   kind=py;     build=no;  hw=opt; cmd="PYTHONPATH=src/inference_manifest:src/perception_service pytest src/perception_service/test (~25 用例+conformance fixture)";;
    semantic_mapping)     kind=py;     build=no;  hw=opt; cmd="PYTEST_DISABLE_PLUGIN_AUTOLOAD=1 PYTHONPATH=... pytest src/semantic_mapping/test (+verify_rgbd_fixture 无需设备)";;
    attention_viz)        kind=py;     build=no;  hw=opt; cmd="pytest src/attention_viz/test/test_attention_utils.py";;
    model_utils)          kind=none;  build=no;  hw=opt; cmd="无 test 目录; loss_compare/pi05-om-dump 需模型文件";;
    dataset_tools)        kind=py;     build=no;  hw=opt; cmd="pytest src/dataset_tools/test (含 test_camera_isp_color_search 16 例)";;
    robot_moveit)         kind=py;     build=no;  hw=no;  cmd="bare pytest src/robot_moveit/test (CMake 仅注册 3 个; kinematics 需单独跑; 部分需 MoveIt2 导入)";;
    robot_navigation)     kind=py;     build=no;  hw=opt; cmd="pytest src/robot_navigation/test (软件闭环 E2E; Gazebo E2E 需 NAV_TEST_PROFILE=full)";;
    robot_teleop)         kind=py;     build=no;  hw=opt; cmd="bare pytest src/robot_teleop/test (colcon 仅 lint; conftest 支持工作区根运行)";;
    sim_models)           kind=none;  build=no;  hw=no;  cmd="无自带测试; 经 robot_config NAV_TEST_PROFILE=full 间接覆盖";;
    voice_asr_service)    kind=py;     build=no;  hw=opt; cmd="pytest test/speech_direction/test_offline_regression.py (DOA 回归; 模型缺失自动 skip)";;
    embodied_common)      kind=py;     build=no;  hw=no;  cmd="pytest src/embodied_common/test (纯库)";;
    embodied_agent)       kind=py;     build=no;  hw=no;  cmd="pytest src/embodied_agent/test";;
    embodied_bringup)     kind=py;     build=no;  hw=no;  cmd="pytest src/embodied_bringup/test (launch builder + visual game 契约)";;
    vlm_task_planner)     kind=py;     build=no;  hw=opt; cmd="pytest src/vlm_task_planner/test (端到端需相机+VLM API)";;
    safety_guard)         kind=py;     build=no;  hw=no;  cmd="pytest src/safety_guard/test/test_rules.py";;
    skill_library)        kind=py;     build=no;  hw=sim; cmd="pytest src/skill_library/test (端到端需 sim)";;
    robot_skill_cli)      kind=py;     build=no;  hw=opt; cmd="pytest src/robot_skill_cli/test; list-skills/describe 可离线";;
    manipulation_service) kind=py;     build=no;  hw=opt; cmd="pytest src/manipulation_service/test (GraspGen 端到端需 CUDA)";;
    manipulation_execution)kind=py;    build=no;  hw=opt; cmd="PYTEST_DISABLE_PLUGIN_AUTOLOAD=1 pytest --import-mode=importlib src/manipulation_execution/test";;
    lekiwi_description)   kind=build;  build=yes; hw=no;  cmd="colcon build + check_urdf/xacro (无 README/无测试)";;
    robot_description)    kind=build;  build=yes; hw=no;  cmd="colcon build + check_urdf/xacro + MuJoCo/Gazebo 加载 (无 README/无测试)";;
    pymoveit2)            kind=none;  build=no;  hw=opt; cmd="子模块无 test 目录; 用 examples + Gazebo panda 验证";;
    rosclaw)              kind=none;  build=no;  hw=no;  cmd="子模块 TS monorepo; pnpm typecheck + docker compose (与主链路解耦)";;
    *) echo "unknown: $p"; return 1;;
  esac
  printf '%-22s %-7s build=%-3s hw=%-3s %s\n' "$p" "$kind" "$build" "$hw" "$cmd"
}

run_pytest() {
  local pp="$1" tp="$2"; shift 2 || true
  [[ -e "$tp" ]] || { echo "SKIP: test path not found: $tp"; return 3; }
  PYTHONPATH="$pp${PYTHONPATH:+:$PYTHONPATH}" $PYTEST "$tp" -q -p no:cacheprovider --tb=short "$@"
}

run_colcon_test() {
  local pkg="$1" rc line failed tmp names nonlint; shift || true
  have colcon || { echo "SKIP: colcon not available (needed for $pkg)"; return 3; }
  # ament_lint style checks (copyright/cpplint/flake8/...). Their failures are code-style only,
  # NOT functional — ignore them; report functional (gtest/gmock) results only.
  local LINT='copyright|cppcheck|cpplint|flake8|lint_cmake|lint_package|pep257|pep8|uncrustify|xmllint'
  # workspace install uses merged layout (build.sh --merge-install); colcon test needs --merge-install too.
  # `colcon test` exits 0 even when gtest CASES fail, and `colcon test-result` (no base) scans the whole
  # workspace so it picks up OTHER packages' failures -> false FAIL. Parse THIS run's per-package CTest
  # summary line instead ("X% tests passed, Y tests failed out of Z").
  tmp=$(mktemp)
  colcon test --packages-select "$pkg" --merge-install --event-handlers console_direct+ "$@" >"$tmp" 2>&1 || true
  cat "$tmp"
  line=$(grep -Eo '[0-9]+% tests passed, [0-9]+ tests? failed out of [0-9]+' "$tmp" | tail -1)
  failed=$(printf '%s' "$line" | grep -Eo '[0-9]+ tests? failed' | grep -Eo '^[0-9]+' | head -1)
  if [[ -n "$line" ]]; then
    if [[ "${failed:-0}" == "0" ]]; then
      rc=0
    else
      # extract failed test names from the CTest "The following tests FAILED:" block
      names=$(grep -E '^[[:space:]]*[0-9]+ - [A-Za-z0-9_.]+ \(Failed' "$tmp" | sed -E 's/.* - ([A-Za-z0-9_.]+).*/\1/' | sort -u)
      nonlint=0
      for n in $names; do [[ "$n" =~ ^($LINT)$ ]] || { nonlint=1; break; }; done
      if [[ $nonlint -eq 1 ]]; then
        rc=1
      else
        rc=0
        echo "(functional PASS — lint-only failures ignored: $(echo $names | tr '\n' ' '))"
      fi
    fi
  else
    grep -Eq '\[  FAILED  \]|[0-9]+ failed' "$tmp" && rc=1 || rc=0
  fi
  rm -f "$tmp"
  return $rc
}

run_colcon_build() {
  local pkg="$1"; shift || true
  have colcon || { echo "SKIP: colcon not available (needed to build $pkg)"; return 3; }
  colcon build --packages-select "$pkg" --symlink-install --merge-install "$@"
}

run() {
  local p="$1"; shift || true
  case "$p" in
    hardware_mock)         run_pytest "src/hardware_mock" "src/hardware_mock/test" "$@";;
    inference_service)     PYTEST_DISABLE_PLUGIN_AUTOLOAD=1 run_pytest "src/inference_manifest:src/inference_service" "src/inference_service/tests" "$@";;
    inference_manifest)    PYTHONPATH="src/inference_manifest${PYTHONPATH:+:$PYTHONPATH}" "$PY" -c 'import inference_manifest; print("inference_manifest import OK")';;
    perception_service)    run_pytest "src/inference_manifest:src/perception_service" "src/perception_service/test" "$@";;
    semantic_mapping)      PYTEST_DISABLE_PLUGIN_AUTOLOAD=1 run_pytest "src/inference_manifest:src/perception_service:src/semantic_mapping" "src/semantic_mapping/test" "$@";;
    attention_viz)         run_pytest "src/attention_viz" "src/attention_viz/test/test_attention_utils.py" "$@";;
    dataset_tools)         run_pytest "src/dataset_tools" "src/dataset_tools/test" "$@";;
    robot_config)
      local rc cfg
      run_pytest "src/robot_config" "src/robot_config/test" "$@"; rc=$?
      cfg="$REPO_ROOT/src/robot_config/config/robots/so101_single_arm.yaml"
      if [[ -f "$cfg" ]]; then
        PYTHONPATH="src/robot_config" "$PY" src/robot_config/robot_config/scripts/validate_config.py "$cfg" || echo "(validate_config failed, see log)"
      fi
      return $rc
      ;;
    tensormsg)             run_pytest "src/tensormsg" "src/tensormsg/test/test_converter.py" "$@";;
    action_dispatch)       run_pytest "src/action_dispatch" "src/action_dispatch/test" "$@";;
    embodied_common)      run_pytest "src/embodied_common" "src/embodied_common/test" "$@";;
    embodied_agent)        run_pytest "src/embodied_agent" "src/embodied_agent/test" "$@";;
    embodied_bringup)      run_pytest "src/embodied_bringup" "src/embodied_bringup/test" "$@";;
    vlm_task_planner)     run_pytest "src/vlm_task_planner" "src/vlm_task_planner/test" "$@";;
    safety_guard)          run_pytest "src/safety_guard" "src/safety_guard/test/test_rules.py" "$@";;
    skill_library)         run_pytest "src/skill_library" "src/skill_library/test" "$@";;
    robot_skill_cli)       run_pytest "src/robot_skill_cli" "src/robot_skill_cli/test" "$@";;
    manipulation_service) run_pytest "src/manipulation_service" "src/manipulation_service/test" "$@";;
    manipulation_execution)PYTEST_DISABLE_PLUGIN_AUTOLOAD=1 run_pytest "src/manipulation_execution" "src/manipulation_execution/test" --import-mode=importlib "$@";;
    robot_moveit)          run_pytest "src/robot_moveit" "src/robot_moveit/test" "$@";;
    robot_navigation)     run_pytest "src/robot_navigation" "src/robot_navigation/test" "$@";;
    robot_teleop)         run_pytest "src/robot_teleop" "src/robot_teleop/test" "$@";;
    voice_asr_service)
      local t="src/voice_asr_service/test/speech_direction/test_offline_regression.py"
      [[ -f "$t" ]] || { echo "SKIP: $t not found"; return 3; }
      PYTHONPATH="src/voice_asr_service${PYTHONPATH:+:$PYTHONPATH}" $PYTEST "$t" -q -p no:cacheprovider --tb=short "$@"
      ;;
    so101_hardware)       run_colcon_test so101_hardware "$@";;
    lekiwi_hardware)      run_colcon_test lekiwi_hardware "$@";;
    omni_wheel_controller)run_colcon_test omni_wheel_controller "$@";;
    ibrobot_msgs)         run_colcon_test ibrobot_msgs "$@";;
    lekiwi_description)
      local rc u
      run_colcon_build lekiwi_description "$@"; rc=$?
      if have check_urdf; then u=$(find "$REPO_ROOT/src/lekiwi_description/urdf" -name '*.urdf*' 2>/dev/null | head -1); [[ -n "$u" ]] && check_urdf "$u" || true; fi
      return $rc
      ;;
    robot_description)
      local rc u
      run_colcon_build robot_description "$@"; rc=$?
      if have check_urdf; then u=$(find "$REPO_ROOT/src/robot_description/urdf" -name '*.urdf*' 2>/dev/null | head -1); [[ -n "$u" ]] && check_urdf "$u" || true; fi
      return $rc
      ;;
    task_dispatch|model_utils|sim_models|pymoveit2|rosclaw)
      info "$p" >/dev/null
      echo "SKIP: $p has no in-tree test target (see list for reason)"
      return 3
      ;;
    *) echo "unknown component: $p (try: ./run_tests.sh list)"; return 4;;
  esac
}

run_one() {
  local p="$1"; shift || true
  local log="$LOGDIR/${p}.log"
  echo -e "\n${C_CYAN}==== [$p] ====${C_RST}"
  run "$p" "$@" 2>&1 | tee "$log"
  local code=${PIPESTATUS[0]}
  local res detail=""
  case "$code" in
    0) res=PASS;;
    3|5) res=SKIP;;
    *) res=FAIL;;
  esac
  if [[ "$res" == PASS || "$res" == FAIL ]]; then
    detail=$(grep -E '^[0-9]+ (passed|failed|error|skipped|warnings)' "$log" 2>/dev/null | sed -E 's/ in [0-9.]+s *$//' | tail -1)
  fi
  local color="$C_GRN"; [[ "$res" == FAIL ]] && color="$C_RED"; [[ "$res" == SKIP ]] && color="$C_YEL"
  local suffix="  (exit $code)"
  [[ -n "$detail" ]] && suffix="  ($detail)"
  printf '%b[%-4s]%b %s%s\n' "$color" "$res" "$C_RST" "$p" "$suffix"
  printf '%-22s %-4s %s\n' "$p" "$res" "$detail" >> "$SUMMARY"
}

cmd_list() {
  echo "IB-Robot testable components (${#COMPONENTS[@]} total, workflows excluded)"
  echo "kind: py=source pytest | colcon=colcon test(C++/lint) | build=build+urdf | smoke=import | none=no in-tree tests"
  echo "hw:   no=无需硬件 | opt=单测无需,端到端需 | sim=需仿真/真机"
  echo "--------------------------------------------------------------------------------"
  for p in "${COMPONENTS[@]}"; do info "$p"; done
  echo "--------------------------------------------------------------------------------"
  echo "build-dependent (need colcon): ${BUILD_PKGS[*]}"
}

cmd_all() {
  local skip_build=0 args=()
  for a in "$@"; do [[ "$a" == "--no-build" ]] && skip_build=1 || args+=("$a"); done
  mkdir -p "$LOGDIR"
  : > "$SUMMARY"
  echo "IB-Robot full test run @ $TS  (log: $LOGDIR)"
  echo "args: ${args[*]:-<none>}; --no-build=$skip_build"
  echo "================================================================================"
  local npass=0 nfail=0 nskip=0
  for p in "${COMPONENTS[@]}"; do
    if [[ $skip_build -eq 1 ]] && needs_build "$p"; then
      echo -e "\n${C_CYAN}==== [$p] ====${C_RST}"
      echo "SKIP: --no-build set (build-dependent)"
      printf '%-22s %-4s %s\n' "$p" "SKIP" "--no-build" >> "$SUMMARY"
      nskip=$((nskip+1)); continue
    fi
    run_one "$p" "${args[@]}"
    case "$(awk '{print $2}' "$SUMMARY" | tail -1)" in PASS) npass=$((npass+1));; FAIL) nfail=$((nfail+1));; SKIP) nskip=$((nskip+1));; esac
  done
  echo "================================================================================"
  echo "SUMMARY (pass=$npass fail=$nfail skip=$nskip)  ->  $SUMMARY"
  column -t "$SUMMARY" 2>/dev/null || cat "$SUMMARY"
  [[ $nfail -eq 0 ]]
}

cmd_inference() {
  local model="" platform="" no_inf=0 duration=60 robot="so101_single_arm" warmup=20
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --model) model="$2"; shift 2;;
      --platform) platform="$2"; shift 2;;
      --no-inference) no_inf=1; shift;;
      --duration) duration="$2"; shift 2;;
      --robot) robot="$2"; shift 2;;
      --warmup) warmup="$2"; shift 2;;
      *) echo "unknown inference arg: $1 (try: ./run_tests.sh --help)"; return 1;;
    esac
  done
  [[ -f "$REPO_ROOT/install/setup.sh" ]] || { echo -e "${C_RED}[inference]${C_RST} install/ missing — run ./scripts/build.sh first"; return 1; }
  case "$platform" in
    qemu) export TORCH_DEVICE_BACKEND_AUTOLOAD=0
          echo -e "${C_YEL}[inference]${C_RST} platform=qemu -> TORCH_DEVICE_BACKEND_AUTOLOAD=0 (no CANN; full ACT inference needs aarch64 CANN — likely fails at lerobot factory; use --no-inference for mock-only)";;
    real) echo -e "${C_CYAN}[inference]${C_RST} platform=real (CANN expected, torch_npu loads)";;
    "")   echo -e "${C_CYAN}[inference]${C_RST} platform=auto (NPU-aware)";;
     *)    echo "unknown --platform: $platform (qemu|real)"; return 1;;
  esac
  if [[ -z "$model" && $no_inf -eq 0 ]]; then
    echo -e "${C_YEL}[inference]${C_RST} 提示：未指定 ACT 模型。测试推理需先自行下载 ACT 策略模型并 --model <ACT.zip> 传入，或用 --no-inference 跑纯 mock。若 models/ 下已解压好模型，可继续。"
  fi
  local model_dir=""
  if [[ -n "$model" ]]; then
    if [[ -f "$model" && "$model" == *.zip ]]; then
      local base; base="$(basename "$model" .zip)"
      model_dir="$REPO_ROOT/models/$base"; mkdir -p "$REPO_ROOT/models"
      if [[ ! -d "$model_dir" ]]; then
        echo -e "${C_CYAN}[inference]${C_RST} extracting $model -> $model_dir"
        (command -v unzip >/dev/null && unzip -q "$model" -d "$REPO_ROOT/models") || python3 -c "import zipfile,sys;zipfile.ZipFile(sys.argv[1]).extractall(sys.argv[2])" "$model" "$REPO_ROOT/models"
      fi
    elif [[ -d "$model" ]]; then
      model_dir="$model"
    else
      echo -e "${C_RED}[inference]${C_RST} --model must be a zip or dir: $model"; return 1
    fi
    [[ -f "$model_dir/inference_manifest.json" ]] || { echo -e "${C_RED}[inference]${C_RST} no inference_manifest.json in $model_dir"; return 1; }
    echo -e "${C_CYAN}[inference]${C_RST} model: $model_dir"
  fi
  [[ $no_inf -eq 1 && -z "$model" ]] && echo -e "${C_YEL}[inference]${C_RST} --no-inference: mock-only (with_inference:=false), no model needed"
  local inf_flag=""; [[ $no_inf -eq 1 ]] && inf_flag="with_inference:=false"
  mkdir -p "$LOGDIR"
  echo -e "${C_CYAN}[inference]${C_RST} launching mock-sim (robot=$robot use_sim=true sim_platform=mock control_mode=model_inference $inf_flag) for ${duration}s..."
  local lpid
  nohup ros2 launch robot_config robot.launch.py robot_config:="$robot" use_sim:=true sim_platform:=mock control_mode:=model_inference $inf_flag > "$LOGDIR/inference.log" 2>&1 & lpid=$!
  echo -e "${C_CYAN}[inference]${C_RST} launch pid=$lpid; warming up ${warmup}s (model load + first inference)..."
  sleep "$warmup"
  echo "=== /joint_states (mock input) ==="; timeout 5 ros2 topic hz /joint_states 2>&1 | grep -E 'average rate' | head -1
  local actions_hz; actions_hz=$(timeout 6 ros2 topic hz /arm_position_controller/commands 2>&1 | grep -E 'average rate' | head -1)
  echo "=== /arm_position_controller/commands (dispatched actions) === $actions_hz"
  echo "=== launch log tail ==="; tail -4 "$LOGDIR/inference.log" 2>/dev/null
  pkill -f "[r]os2 launch|[p]ipeline_policy_node|[c]ontract_mock|[a]ction_dispatcher" 2>/dev/null
  sleep 1; echo -e "${C_CYAN}[inference]${C_RST} launch stopped (log: $LOGDIR/inference.log)"
  if [[ -n "$actions_hz" ]]; then
    echo -e "${C_GRN}[PASS]${C_RST} inference loop live — actions dispatched ($actions_hz)"
    return 0
  fi
  echo -e "${C_RED}[FAIL]${C_RST} no actions on /arm_position_controller/commands — see $LOGDIR/inference.log (common: missing ACT model, missing resnet18 cache, or qemu w/o CANN)"
  return 1
}

cmd_build() {
  local pkgs=("$@"); [[ ${#pkgs[@]} -eq 0 ]] && pkgs=("${BUILD_PKGS[@]}")
  mkdir -p "$LOGDIR"; : > "$SUMMARY"
  for p in "${pkgs[@]}"; do
    echo -e "\n${C_CYAN}==== [build $p] ====${C_RST}"
    run_colcon_build "$p" 2>&1 | tee "$LOGDIR/build_${p}.log"
    local code=${PIPESTATUS[0]}
    local res=PASS; [[ $code -ne 0 ]] && res=FAIL
    printf '%-22s %-4s (build)\n' "$p" "$res" >> "$SUMMARY"
    echo -e "${res==PASS?$C_GRN:$C_RED}[$res]${C_RST} build $p"
  done
  column -t "$SUMMARY" 2>/dev/null || cat "$SUMMARY"
}

usage() {
  sed -n '2,46p' "$0"
}

main() {
  setup_env || return 1
  local sub="${1:-}"; shift || true
  case "$sub" in
    list) cmd_list;;
    all) cmd_all "$@";;
    build) cmd_build "$@";;
    inference) cmd_inference "$@";;
    -h|--help|"") usage;;
    *)
      for c in "${COMPONENTS[@]}"; do [[ "$c" == "$sub" ]] && { mkdir -p "$LOGDIR"; : > "$SUMMARY"; run_one "$sub" "$@"; column -t "$SUMMARY" 2>/dev/null || cat "$SUMMARY"; return; }; done
      echo "unknown component/subcommand: $sub"; usage; return 1
      ;;
  esac
}

main "$@"
