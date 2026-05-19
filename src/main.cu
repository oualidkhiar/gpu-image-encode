#define STB_IMAGE_IMPLEMENTATION
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "../includes/stb_image.h"
#include "../includes/stb_image_write.h"
#include <stdio.h>
#include <unistd.h>
#include <iostream>


__global__ void encode_decode_kernel(unsigned char *d_img, size_t size)
{
    int index = blockIdx.x * blockDim.x + threadIdx.x;

    if (index < size) {
        d_img[index] ^= (index % 256);
    }
}

__host__ unsigned char *process_image_GPU(unsigned char *img, int width, int height, int channels)
{
    size_t size =  (width * height * channels * sizeof(unsigned char));

    unsigned char *new_image = new unsigned char[size];

    if (!new_image) {
        std::cerr << "faild to allocate for new image" << std::endl;
        return NULL;
    }

    unsigned char *d_img;

    cudaMalloc(&d_img, size); 

    cudaMemcpy(d_img, img, size, cudaMemcpyHostToDevice);

    int threads = 256;
    int blocks = (size + threads - 1) / threads;

    encode_decode_kernel<<<blocks, threads>>>(
        d_img, 
        size
    );

    cudaDeviceSynchronize();

    cudaMemcpy(new_image, d_img, size, cudaMemcpyDeviceToHost);

    cudaFree(d_img);

    return new_image;
}

__host__ void print_image_pixels(unsigned char *img, int width, int height, int channels)
{
    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
        
            int index = (i * width + j) * channels;
        
            unsigned char r = img[index];
            unsigned char g = img[index + 1];
            unsigned char b = img[index + 2];
        
            std::cout << "Pixel (" << i << "," << j << ") = "
                      << (int)r << " "
                      << (int)g << " "
                      << (int)b << std::endl;
        }
    }
}

__host__ int main(int ac, char **av)
{
    if (ac != 2) {
        std::cerr << "Usage: ./program image_file_name" << std::endl;
        return 1;
    }

    int width = 0, height = 0, channels = 0;

    unsigned char *img = stbi_load(av[1], &width, &height, &channels, 0);

    if (img == NULL) {
        std::cerr << "Error: fiald to load image" << std::endl;
        return 1;
    }

    unsigned char *new_image = process_image_GPU(img, width, height, channels);

    int ret = stbi_write_png(av[1], width, height, channels, new_image, width * channels);

    if (!ret) {
        std::cerr << "Error: faild to write back new image" << std::endl;
        return 1;
    }

    stbi_image_free(img);

    delete[] new_image;

    return 0;
}