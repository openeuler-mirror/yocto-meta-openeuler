构建Mindspore Lite使用指导
#########################

本章主要介绍如何构建Mindspore Lite，以及如何应用其进行端侧推理。

.. note::

   在构建前，请确保构建主机满足以下条件：

   - 至少有 **8G** 内存。
   - 建议有 **200G** 以上存储。
   - 建议使用内存、CPU数量更多的主机，增加构建速度。

简介
************************
MindSpore Lite是MindSpore推出的轻量级、高性能AI推理框架，旨在满足端侧设备上日益增长的AI应用需求。它专注于在移动设备和物联网（IoT）设备上部署和运行AI模型，已广泛应用于图像分类、目标识别、人脸识别、文字识别等领域。

更详尽的信息及使用指南可参考官网：https://www.mindspore.cn/lite/?version=r2.0

功能介绍
************************

当前集成版本为r2.3.1，主要集成端侧推理核心包，未集成Mindspore Lite相关工具（如模型转换等），具体功能为：可以调用已有的ms模型在嵌入式设备上进行直接推理。

第 1 步: 构建准备
************************

1. 准备一个 ubuntu x86 构建主机环境 （建议22.04）

2. openEuler镜像构建准备，下述操作摘自官方使用指南：https://pages.openeuler.openatom.cn/embedded/docs/build/html/master/getting_started/index.html

3. 安装必要的软件包

   .. code-block:: shell

     $ sudo apt-get install python3 python3-pip docker docker.io
     $ pip install oebuild

4. 配置docker环境

   .. code-block:: shell

     $ sudo usermod -a -G docker $(whoami)
     $ sudo systemctl daemon-reload && sudo systemctl restart docker
     $ sudo chmod o+rw /var/run/docker.sock

5. 初始化oebuild构建环境

   .. code-block:: shell

     # <work_dir> 为要创建的工作目录
     $ oebuild init <work_dir>

     # 进入工作目录
     $ cd <work_dir>

     # 拉取构建容器、yocto-meta-openeuler 项目代码
     $ oebuild update

第 2 步： 执行构建
************************

1. 进入工作目录

   .. code-block:: shell

     $ cd <work_dir>

2. 创建配置文件

   .. code-block:: shell

     $ oebuild generate -p qemu-aarch64 -d build_arm64

3. 切换到包含 compile.yaml 的编译空间目录

   .. code-block:: shell

     $ cd build/build_arm64/

4. 进入交互环境

   .. code-block:: shell

     $ oebuild bitbake

5. 执行构建

   .. code-block:: shell

     $ bitbake mindspore-lite

第 3 步 执行推理 （Demo）
************************
我们集成了一个简易Demo执行推理，通过调用mobilenet实现简单的图像分类，在本步中，我们直接运行Demo，具体如何定制化构建将在下一步介绍。

**（示例支持arm64通用，无后端定制，欢迎厂商贡献后端驱动）**

1. 添加 MindSpore Lite 和 Demo 到 openEuler 镜像：

   - 进入镜像配置文件夹，地址如下：

     .. code-block:: shell

        <work_dir>/src/yocto-meta-openeuler/meta-openeuler/recipes-core/images

   - 添加 MindSpore Lite、Demo Classification 和 OpenCV，示例如下：

     .. code-block:: shell

        IMAGE_INSTALL += " \
        ${@bb.utils.contains("DISTRO_FEATURES", "mcs", "packagegroup-mcs", "", d)} \
        ${@bb.utils.contains("DISTRO_FEATURES", "ros", "packagegroup-ros", "", d)} \
        ${@bb.utils.contains("DISTRO_FEATURES", "hmi", "packagegroup-hmi", "", d)} \
        ${@bb.utils.contains("DISTRO_FEATURES", "kubeedge isulad", "packagegroup-kubeedge", "", d)} \
        ${@bb.utils.contains("DISTRO_FEATURES", "isulad", "packagegroup-isulad", "", d)} \
        mindspore-lite demo-classification opencv \
        "


2. 构建镜像，产物在output文件夹下

   .. code-block:: shell

      $ bitbake openeuler-image

2. 配置网络信息，根据官网文档中“使能本地网络”执行操作，具体参考：
   https://pages.openeuler.openatom.cn/embedded/docs/build/html/master/developer_guide/debug/qemu/qemu_start.html?highlight=qemu%20net

3. 运行并进入QEMU中，Demo的图片存放在 `/usr/pictures` 中，同时，由于在上一步中实现了本地网络配置，可以通过 `scp` 工具把主机中的图片传输到 QEMU 中，之后根据图片文件名称执行推理：

   .. code-block:: shell

      $ ms-demo-class /usr/model/mobilenetv2.ms /usr/pictures/tench.webp /usr/pictures/labels.txt

   其中，`mobilenetv2.ms` 是我们的模型，`tench.webp` 是图片名称，由于一些冲突问题，当前仅支持 webp 格式的图片，请注意；`labels.txt` 是标签文件。

   执行推理后，会返回图像的预测结果：

   .. code-block:: text

      ------- print outputs ----------
      Predicted class index: 0
      Predicted label: tench, Tinca tinca
      ------- print end ----------

   执行推理的结果可能因模型和输入图片的不同而有所变化，请根据实际情况调整。

第 4 步 自行构建推理
************************

如果希望更改demo或者应用在其他项目中，可以自行编写代码并配置，具体mindspore及demo的文件结构为：

.. code-block:: text

   mindspore-lite/
   ├── files/
   │   ├── demo-class/
   │   │   ├── model/
   │   │   ├── CMakeLists.txt
   │   │   └── main.cc
   │   ├── pictures/
   │   └── yocto-mslite-aarch64-supprot.patch
   ├── demo-classification_1.0.bb
   └── mindspore-lite_2.3.2.bb

在自行设计推理时，可以修改demo-classification_1.0.bb， main.cc， CMakeLists.txt文件，由于模型文件过大，这里我们采用了在recipe中编写链接下载，没有直接存储。
如果希望获得模型源文件可访问：https://download-mindspore.osinfra.cn/model_zoo/official/lite/quick_start/mobilenetv2.ms

具体文件内容为（可根据实际情况修改）：

demo-classification_1.0.bb

.. code-block:: shell

    DESCRIPTION = "Application demo for mindspore-lite"
    AUTHOR = "Huawei Technologies Co., Ltd"
    LICENSE = "CLOSED"

    SRC_URI = " \
    file://demo-class \
    file://pictures/ \
    https://download-mindspore.osinfra.cn/model_zoo/official/lite/quick_start/mobilenetv2.ms;name=model \
    "

    SRC_URI[model.sha256sum] = "5a7ccd53bf92d8b294a703a1302d4230a311b2d19a8d212eedd65ff6838cfa84"

    # Source directory
    S = "${WORKDIR}/demo-classification"

    DEPENDS = "mindspore-lite opencv"

    # Inherit pkg
    inherit cmake

    EXTRA_OECMAKE += "-DCMAKE_CXX_FLAGS=-I${STAGING_INCDIR}/opencv4"
    EXTRA_OECMAKE += "-DCMAKE_EXE_LINKER_FLAGS=-L${STAGING_LIBDIR}"

    do_configure:prepend(){
        cp -rf ${WORKDIR}/demo-class/* ${S}
        cp ${WORKDIR}/mobilenetv2.ms ${S}/model
    }

    do_configure[depends] += "opencv:do_populate_sysroot mindspore-lite:do_populate_sysroot"

    # Install the demo binary
    do_install() {
        install -d ${D}${bindir}
        install -m 0755 ${B}/ms-demo-class ${D}${bindir}/
        install -d ${D}/usr/model
        install -m 0755 ${WORKDIR}/mobilenetv2.ms ${D}/usr/model
        install -d ${D}/usr/pictures
        cp -r ${WORKDIR}/pictures/* ${D}/usr/pictures/
    }

    # Specify files to package
    FILES:${PN} = "${bindir}/ms-demo-class /usr/model /usr/pictures"


main.cc

.. code-block:: c

    #include <iostream>
    #include <fstream>
    #include <opencv2/opencv.hpp>
    #include <opencv2/imgcodecs.hpp>
    #include <opencv2/highgui.hpp>
    #include "include/api/model.h"
    #include "include/api/context.h"
    #include "include/api/status.h"
    #include "include/api/types.h"
    #include <vector>
    #include <string>
    #include <map>
    #include <sstream>
    #include <regex>

    using mindspore::MSTensor;

    // Function to read model file
    char *ReadFile(const char *file, size_t *size) {
        if (file == nullptr) {
            std::cerr << "file is nullptr." << std::endl;
            return nullptr;
        }

        std::ifstream ifs(file, std::ifstream::in | std::ifstream::binary);
        if (!ifs.good()) {
            std::cerr << "file: " << file << " is not exist." << std::endl;
            return nullptr;
        }

        if (!ifs.is_open()) {
            std::cerr << "file: " << file << " open failed." << std::endl;
            return nullptr;
        }

        ifs.seekg(0, std::ios::end);
        *size = ifs.tellg();
        std::unique_ptr<char[]> buf(new (std::nothrow) char[*size]);
        if (buf == nullptr) {
            std::cerr << "malloc buf failed, file: " << file << std::endl;
            ifs.close();
            return nullptr;
        }

        ifs.seekg(0, std::ios::beg);
        ifs.read(buf.get(), *size);
        ifs.close();

        return buf.release();
    }

    // Function to load labels from the provided dictionary-style labels.txt
    std::map<int, std::string> LoadLabels(const std::string &label_file) {
        std::map<int, std::string> labels;
        std::ifstream file(label_file);
        std::string content((std::istreambuf_iterator<char>(file)), std::istreambuf_iterator<char>());

        // Regular expression to match {index: 'label'}
        std::regex pattern(R"(\s*(\d+)\s*:\s*'([^']*)')");
        std::smatch match;

        auto labels_begin = std::sregex_iterator(content.begin(), content.end(), pattern);
        auto labels_end = std::sregex_iterator();

        for (std::sregex_iterator i = labels_begin; i != labels_end; ++i) {
            std::smatch match = *i;
            int index = std::stoi(match[1].str());  // Extract the index
            std::string label = match[2].str();     // Extract the label
            labels[index] = label;
        }

        return labels;
    }

    // Function to preprocess image, resize it to model's input size and normalize
    std::vector<float> PreprocessImage(std::string image_path, int target_height, int target_width) {
        // Read the image
        cv::Mat image = cv::imread(image_path, cv::IMREAD_COLOR);
        if (image.empty()) {
            std::cerr << "Failed to read image: " << image_path << std::endl;
            return {};
        }

        // Resize the image to the target size
        cv::resize(image, image, cv::Size(target_width, target_height));

        // Convert the image to float32 and normalize to [0, 1]
        image.convertTo(image, CV_32F, 1.0 / 255.0);

        // Flatten the image data into a vector
        std::vector<float> input_data;
        input_data.assign(image.begin<float>(), image.end<float>());

        return input_data;
    }

    int main(int argc, const char **argv) {
        // Check input arguments for model path, image path, and labels path
        if (argc < 4) {
            std::cerr << "Usage: " << argv[0] << " <model_path> <image_path> <label_path>" << std::endl;
            return -1;
        }

        std::string model_path = argv[1];
        std::string image_path = argv[2];
        std::string label_path = argv[3];

        // Load labels
        std::map<int, std::string> labels = LoadLabels(label_path);
        if (labels.empty()) {
            std::cerr << "Failed to load labels from: " << label_path << std::endl;
            return -1;
        }

        // Read model file
        size_t size = 0;
        char *model_buf = ReadFile(model_path.c_str(), &size);
        if (model_buf == nullptr) {
            std::cerr << "Read model file failed." << std::endl;
            return -1;
        }

        // Create and init context, add CPU device info
        auto context = std::make_shared<mindspore::Context>();
        if (context == nullptr) {
            delete[](model_buf);
            std::cerr << "New context failed." << std::endl;
            return -1;
        }
        auto &device_list = context->MutableDeviceInfo();
        auto device_info = std::make_shared<mindspore::CPUDeviceInfo>();
        if (device_info == nullptr) {
            delete[](model_buf);
            std::cerr << "New CPUDeviceInfo failed." << std::endl;
            return -1;
        }
        device_list.push_back(device_info);

        // Create model
        auto model = new (std::nothrow) mindspore::Model();
        if (model == nullptr) {
            delete[](model_buf);
            std::cerr << "New Model failed." << std::endl;
            return -1;
        }

        // Build model
        auto build_ret = model->Build(model_buf, size, mindspore::kMindIR, context);
        delete[](model_buf);
        if (build_ret != mindspore::kSuccess) {
            delete model;
            std::cerr << "Build model error " << std::endl;
            return -1;
        }

        // Preprocess the input image
        int input_height = 224;  // MobileNetV2 input size
        int input_width = 224;
        std::vector<float> input_data = PreprocessImage(image_path, input_height, input_width);
        if (input_data.empty()) {
            delete model;
            return -1;
        }

        // Get Input
        auto inputs = model->GetInputs();
        for (auto &tensor : inputs) {
            auto input_data_ptr = reinterpret_cast<float *>(tensor.MutableData());
            if (input_data_ptr == nullptr) {
                std::cerr << "MallocData for inTensor failed." << std::endl;
                delete model;
                return -1;
            }
            memcpy(input_data_ptr, input_data.data(), input_data.size() * sizeof(float));
        }

        // Predict
        std::vector<MSTensor> outputs;
        auto status = model->Predict(inputs, &outputs);
        if (status != mindspore::kSuccess) {
            std::cerr << "Inference error." << std::endl;
            delete model;
            return -1;
        }

        // Post-process: Get the class with highest probability and print corresponding label
        std::cout << "\n------- print outputs ----------" << std::endl;
        for (auto tensor : outputs) {
            auto out_data = reinterpret_cast<float *>(tensor.MutableData());
            int class_idx = std::max_element(out_data, out_data + tensor.ElementNum()) - out_data;
            std::cout << "Predicted class index: " << class_idx << std::endl;
            if (labels.find(class_idx) != labels.end()) {
                std::cout << "Predicted label: " << labels[class_idx] << std::endl;
            } else {
                std::cerr << "Invalid class index" << std::endl;
            }
        }
        std::cout << "------- print end ----------\n" << std::endl;

        // Delete model
        delete model;
        return mindspore::kSuccess;
    }


CMakeLists.txt

.. code-block:: text

    cmake_minimum_required(VERSION 3.12)
    project(Demo)

    include_directories($ENV{PKG_CONFIG_SYSROOT_DIR}/usr/)
    link_directories($ENV{PKG_CONFIG_SYSROOT_DIR}/usr/lib64)

    find_package(OpenCV REQUIRED)

    add_executable(ms-demo-class main.cc)

    target_link_libraries(
            ms-demo-class
            ${OpenCV_LIBS}
            mindspore-lite
            pthread
            dl
    )







