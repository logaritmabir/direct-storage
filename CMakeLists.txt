cmake_minimum_required(VERSION 3.17)

project(dstorage)

cmake_policy(SET CMP0104 NEW)
set(CMAKE_CUDA_ARCHITECTURES 75)

enable_language(CUDA)

# set(CUDA_TOOLKIT_ROOT_DIR "/usr/local/cuda-12.2/bin")

find_package(CUDA REQUIRED)
include_directories(${CUDA_INCLUDE_DIRS})

# CUDA source files
set(CUDA_FILES
    faster_faster.cu
    faster_faster.cuh
)

# Set CUDA compilation flags (optional)
set(CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS};-O3)
set(CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS};-arch=sm_75)
set(CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS};--expt-relaxed-constexpr)

# Create an executable that includes CUDA files
add_executable(${PROJECT_NAME} ${CUDA_FILES} main.cu)  # Add main.cpp or your main source file here

# Link OpenCV and CUDA dependencies to the target
target_link_libraries(${PROJECT_NAME} ${CUDA_LIBRARIES} cufile)