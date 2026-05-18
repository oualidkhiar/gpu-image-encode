#define STB_IMAGE_IMPLEMENTATION
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "../includes/stb_image.h"
#include "../includes/stb_image_write.h"
#include <stdio.h>
#include <unistd.h>
#include <iostream>

void print_image_pixels(unsigned char *img, int width, int height, int channels)
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

_global_ void encode_kernel(unsigned char *img, int width, int height)
{

}

_global_ void decode_kernel()
{

}

unsigned char *process_image_GPU(unsigned char *img, int width, int height, int channels)
{
    /*
        here we start calling cuda APIS for performing Gpu PROCESSING FOR IMAGE 
    */

    unsigned char *new_image = new unsigned char[(height * width)];

    if (!new_image) {
        std::cerr << "faild to allocate for new image" << std::endl;
        return NULL;
    }
    

    encode_kernel<<4, 1<<(img, width, height);

}

int main(int ac, char **av)
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

    print_image_pixels(img, width, height, channels); // original image

    unsigned char *new_image = process_image_GPU(img, width, height, channels);

    print_image_pixels(new_image, width, height, channels); // new image

    int ret = stbi_write_png("../image/output_new_image.png", width, height, channels, new_image, width * channels);

    if (!ret) {
        std::cerr << "Error: faild to write back new image" << std::endl;
        return 1;
    }

    stbi_image_free(img);

    return 0;
}