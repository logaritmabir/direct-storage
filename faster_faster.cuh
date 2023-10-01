#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <cufile.h>
#include <sys/stat.h>
#include <iomanip>
#include <iostream>

constexpr int BUFFER_SIZE = (128 * 1024UL);

int open_with_cufile();