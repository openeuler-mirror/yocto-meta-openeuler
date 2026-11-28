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
// Lines look like "{N: 'label text', ...}". Entries whose text contains an
// apostrophe are quoted with double quotes instead, so accept both styles.
std::map<int, std::string> LoadLabels(const std::string &label_file) {
    std::map<int, std::string> labels;
    std::ifstream file(label_file);
    std::string line;
    std::regex pattern(R"(^\s*\{?(\d+)\s*:\s*(['"])(.*)\2\s*,?\s*\}?\s*$)");
    std::smatch match;
    while (std::getline(file, line)) {
        if (std::regex_match(line, match, pattern)) {
            labels[std::stoi(match[1].str())] = match[3].str();
        }
    }
    return labels;
}

// Function to preprocess image, resize it to model's input size and normalize.
// This replicates the preprocessing of the official MindSpore Lite image
// classification demo: bilinear resize to 256x256, scale to [0, 1],
// center crop 224x224, then ImageNet per-channel mean/std normalization.
std::vector<float> PreprocessImage(std::string image_path, int target_height, int target_width) {
    // Read the image
    cv::Mat image = cv::imread(image_path, cv::IMREAD_COLOR);
    if (image.empty()) {
        std::cerr << "Failed to read image: " << image_path << std::endl;
        return {};
    }

    // Bilinear resize to 256x256 and scale to [0, 1]
    cv::resize(image, image, cv::Size(256, 256), 0, 0, cv::INTER_LINEAR);
    image.convertTo(image, CV_32F, 1.0 / 255.0);

    // OpenCV reads BGR; convert to RGB so the channel order matches the
    // ImageNet mean/std constants below (R, G, B)
    cv::cvtColor(image, image, cv::COLOR_BGR2RGB);

    // Center crop 224x224 (the target must fit the 256x256 resize)
    if (target_width > 256 || target_height > 256) {
        std::cerr << "Crop target " << target_width << "x" << target_height
                  << " does not fit the 256x256 resized input" << std::endl;
        return {};
    }
    int x = (256 - target_width) / 2;
    int y = (256 - target_height) / 2;
    image = image(cv::Rect(x, y, target_width, target_height)).clone();

    // ImageNet per-channel mean/std normalization
    const float mean[] = {0.485f, 0.456f, 0.406f};
    const float stddev[] = {0.229f, 0.224f, 0.225f};
    std::vector<cv::Mat> channels(3);
    cv::split(image, channels);
    for (int i = 0; i < 3; i++) {
        channels[i] = (channels[i] - mean[i]) / stddev[i];
    }
    cv::merge(channels, image);

    // Flatten the image data into a vector. The Mat is multi-channel
    // (CV_32FC3), so Mat::begin<float>() would trip its
    // elemSize() == sizeof(_Tp) assertion; walk the raw buffer instead.
    std::vector<float> input_data;
    const float *p = reinterpret_cast<const float *>(image.ptr());
    input_data.assign(p, p + image.total() * image.channels());

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
    // ImageNet-1k: warn (do not fail) if not exactly 1000 entries were
    // parsed; the hard output-size validation below will catch any real
    // mismatch between the parsed labels and the model output.
    constexpr int kExpectedLabelCount = 1000;
    if (labels.size() != kExpectedLabelCount) {
        std::cerr << "Warning: parsed " << labels.size()
                  << " labels, expected " << kExpectedLabelCount << std::endl;
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

    // Post-process: Get the class with highest probability and print the
    // corresponding label. The model has 1001 outputs: index 0 is the
    // background class and the 1000 real ImageNet classes follow at
    // offset 1 (the MindSpore mobilenetv2 training convention), so the
    // label index is one less than the output index.
    //
    // Validate the output size against the parsed label count first:
    // anything but an exact or +1 match means the labels file did not
    // parse cleanly and every printed label would be silently off, so
    // fail loudly instead of guessing.
    std::cout << "\n------- print outputs ----------" << std::endl;
    for (auto tensor : outputs) {
        auto out_data = reinterpret_cast<float *>(tensor.MutableData());
        size_t element_num = tensor.ElementNum();
        if (element_num != labels.size() && element_num != labels.size() + 1) {
            std::cerr << "Output class count " << element_num
                      << " does not match the " << labels.size()
                      << " labels parsed from " << label_path << std::endl;
            delete model;
            return -1;
        }
        int base = (element_num == labels.size() + 1) ? 1 : 0;
        int output_idx = std::max_element(out_data + base, out_data + element_num) - out_data;
        int label_idx = output_idx - base;
        std::cout << "Predicted class index: " << label_idx << std::endl;
        if (labels.find(label_idx) != labels.end()) {
            std::cout << "Predicted label: " << labels[label_idx] << std::endl;
        } else {
            std::cerr << "Invalid class index" << std::endl;
        }
    }
    std::cout << "------- print end ----------\n" << std::endl;

    // Delete model
    delete model;
    return mindspore::kSuccess;
}

