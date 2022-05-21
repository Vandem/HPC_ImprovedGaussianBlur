// TODO: make gauss kernel local

__kernel void calculate_pixel(
    __global const unsigned char* ImgIn,
    __local const unsigned char* partition,
    __global const float* GaussKernel,
    int radius,
    int width,
    int height,
    bool orientation,
    __global unsigned char* ImgOut)
{
    //int pixel = get_global_id(0);
    int pixel = get_local_id(0);
    int workGroupId = get_group_id(0);
    int workGroupSize = get_num_groups(0);

    

    int diameter = radius * 2 + 1;
    // potential bug
    //int size = sizeof(*partition);

    // col-wise
    //int width = workGroupSize;
    int row = pixel;
    int col = workGroupId;
    int limit = height;
    // row-wise
    if (orientation) {
        //width = size;
        row = workGroupId;
        col = pixel;
        limit = width;
    }
    if (pixel == 0)
    {
        for (int i = 0; i < limit; i++) {
            //partition[i] = ImgIn[3 * row * width + 3 * col + c];
            // row-wise
            partition[i] = ImgIn[3 * row * width + 3 * i + c];
            // col-wise
            partition[i] = ImgIn[3 * i * width + 3 * col + c];
        }
    }

    if (pixel == 0)
    {
        for (int i = 0; i < width; i++) {
            partition[i] = ImgIn[3 * row * width + 3 * col + c];
        }
        partition = ImgIn[]
        printf("radius: %d \n", radius);
        printf("diameter: %d \n", diameter);
        printf("partition size: %d \n", size);
    }

    for (int c = 0; c < 3; c++)
    {
        float sum = 0;
        float sumKernel = 0;

        for (int x = -radius; x <= radius; x++)
        {
            float kernelValue = GaussKernel[x + radius];

            int currentPixel = pixel;

            if ((pixel + x) >= 0 && (pixel + x) < size)
            {
                currentPixel += x;
            }

            //float color = partition[rowPixel * 3 * width + colPixel * 3 + c];
            float color = partition[currentPixel * 3 + c];
            // RGB RGB
            // 012 345 | 678 91011 | 
            sum += color * kernelValue;
            sumKernel += kernelValue;
        }

        ImgOut[3 * row * width + 3 * col + c] = sum / sumKernel;
    }
}