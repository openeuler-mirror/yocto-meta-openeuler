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

