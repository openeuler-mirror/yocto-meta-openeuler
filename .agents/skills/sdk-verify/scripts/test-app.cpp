#include <iostream>
#include <string>
#include <vector>

int main()
{
    std::vector<std::string> v{"SDK", "C++", "works"};
    std::cout << "Hello from SDK-built C++ program: ";
    for (auto &s : v)
        std::cout << s << " ";
    std::cout << std::endl;
    return 0;
}
