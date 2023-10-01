#include "faster_faster.cuh"

#define CHECK_CUDA_ERROR(val) check((val), __FILE__, __LINE__)
template <typename T>
void check(T err, const char* file, const int line)
{
	if (err != cudaSuccess)
	{
		std::cerr << "CUDA Runtime Error at: " << file << ":" << line << std::endl;
		std::cerr << cudaGetErrorString(err) << std::endl;
		std::exit(EXIT_FAILURE);
	}
}

__global__ void increment(int8_t* ptr);

int open_with_cufile(){
    int f_desc = -1;
    int ret = -1;

    CUfileError_t cf_stat;
    CUfileDescr_t cf_desc;
    CUfileHandle_t cf_handle;

    const char* file_path = "/home/ben/Desktop/direct-storage/demo.txt";

    f_desc = open(file_path, O_CREAT | O_RDWR | O_DIRECT); /*API requires O_DIRECT MODE*/
    if (f_desc < 0){
        std::cerr << "The file has not been opened..ERROR" << std::endl;
        return -1;
    }else{
        std::cout << "File has been opened properly..PASSED" << std::endl;
    }

    struct stat file_stats;
    ret = fstat(f_desc,&file_stats);
    if(ret == -1){
        std::cout << "File stats has not been occured..ERROR" << std::endl;
    }else{
        std::cout << "The file is : "<< file_stats.st_size <<" bytes..PASSED" << std::endl;
    }

    size_t size_of_file = file_stats.st_size;

    memset((void *)&cf_desc,0,sizeof(CUfileDescr_t));

    cf_desc.handle.fd = f_desc;
    cf_desc.type = CU_FILE_HANDLE_TYPE_OPAQUE_FD; /*That means this is linux based file*/
    cf_stat = cuFileHandleRegister(&cf_handle,&cf_desc);
    if(cf_stat.err == CU_FILE_SUCCESS){
        std::cout << "File has been handled successfully..PASSED" << std::endl;
    }else{
        std::cerr << "The file has not been opened..ERROR" << std::endl;
        return -1;
    }

    int8_t* dev_ptr = nullptr;
    CHECK_CUDA_ERROR(cudaMalloc((int8_t**)&dev_ptr,size_of_file));
    CHECK_CUDA_ERROR(cudaMemset((int8_t*)dev_ptr,0,size_of_file));
    CHECK_CUDA_ERROR(cudaStreamSynchronize(0)); /*wait until operations are done*/

    ret = cuFileRead(cf_handle,dev_ptr,size_of_file,0,0); /*returns size of bytes successfully written*/
    if(ret < 0){
        std::cerr << "Something went wrong while reading..ERROR" << ret << std::endl;
    }else{
        std::cout << "Read bytes :" << ret << "..PASSED" <<std::endl;
    }
    increment<<<1,9>>>((int8_t *)dev_ptr);
    CHECK_CUDA_ERROR(cudaDeviceSynchronize());

    ret = cuFileWrite(cf_handle,dev_ptr,size_of_file,0,0); /*returns size of bytes successfully written*/
    if(ret < 0){
        std::cerr << "Something went wrong while writing..ERROR" << ret << std::endl;
    }else{
        std::cout << "Written bytes :" << ret << "..PASSED" <<std::endl;
    }

    CHECK_CUDA_ERROR(cudaFree(dev_ptr));
    cuFileHandleDeregister(cf_handle);
    close(f_desc);
    return 0;
}

__global__ void increment(int8_t* ptr){
    int threadId = blockIdx.x * blockDim.x + threadIdx.x;
    ptr[threadId]+=1;
}