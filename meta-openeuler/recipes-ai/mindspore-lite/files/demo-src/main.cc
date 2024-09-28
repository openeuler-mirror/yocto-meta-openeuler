#include <iostream>
#include <fstream>
#include <random>
#include "include/api/model.h"
#include "include/api/context.h"
#include "include/api/status.h"
#include "include/api/types.h"
using mindspore::MSTensor;

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

template <typename T, typename Distribution>
void GenerateRandomData(int size, void *data, Distribution distribution) {
  std::mt19937 random_engine;
  int elements_num = size / sizeof(T);
  (void)std::generate_n(static_cast<T *>(data), elements_num,
                        [&distribution, &random_engine]() { return static_cast<T>(distribution(random_engine)); });
}

int main(int argc, const char **argv) {
  // Read model file.
  std::string model_path = "/usr/model/mobilenetv2.ms";
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

  // Get Input
  auto inputs = model->GetInputs();
  for (auto tensor : inputs) {
    auto input_data = reinterpret_cast<float *>(tensor.MutableData());
    if (input_data == nullptr) {
      std::cerr << "MallocData for inTensor failed." << std::endl;
      delete model;
      return -1;
    }
    GenerateRandomData<float>(tensor.DataSize(), input_data, std::uniform_real_distribution<float>(0.1f, 1.0f));
  }

  // Predict
  std::vector<MSTensor> outputs;
  auto status = model->Predict(inputs, &outputs);
  if (status != mindspore::kSuccess) {
    std::cerr << "Inference error." << std::endl;
    delete model;
    return -1;
  }

  // Get Output Tensor Data.
  std::cout << "\n------- print outputs ----------" << std::endl;
  for (auto tensor : outputs) {
    std::cout << "out tensor name is:" << tensor.Name() << "\nout tensor size is:" << tensor.DataSize()
              << "\nout tensor elements num is:" << tensor.ElementNum() << std::endl;
    auto out_data = reinterpret_cast<float *>(tensor.MutableData());
    std::cout << "output data is:";
    for (int i = 0; i < tensor.ElementNum(); i++) {
      std::cout << out_data[i] << " ";
    }
    std::cout << std::endl;
  }
  std::cout << "------- print end ----------\n" << std::endl;

  // Delete model.
  delete model;
  return mindspore::kSuccess;
}

