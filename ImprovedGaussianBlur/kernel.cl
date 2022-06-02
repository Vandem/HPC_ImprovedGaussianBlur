__kernel void calculate_pixel(
	__global const unsigned char* ImgIn,
	__global const float* GaussKernel,
	int radius,
	int width,
	int height,
	int orientation,
	__global unsigned char* ImgOut,
	__local unsigned char* partition)
{
	int pixel = get_local_id(0);
	int workGroupId = get_group_id(0);

	// col-wise
	int row = pixel;
	int col = workGroupId;
	int limit = height;
	// row-wise
	if (orientation == 1) {
		row = workGroupId;
		col = pixel;
		limit = width;
	}

	for (int c = 0; c < 3; c++) {
		partition[pixel * 3 + c] = ImgIn[3 * row * width + 3 * col + c];
	}

	barrier(CLK_LOCAL_MEM_FENCE);

	for (int c = 0; c < 3; c++)
	{
		float sum = 0;
		float sumKernel = 0;
		int kernelPixel = 0;

		for (int x = -radius; x <= radius; x++)
		{
			float kernelValue = GaussKernel[x + radius];

			if ((pixel + x) < 0) {
				kernelPixel = 0;
			}
			else if ((pixel + x) >= limit) {
				kernelPixel = limit - 1;
			}
			else {
				kernelPixel = pixel + x;
			}
			float color = partition[kernelPixel * 3 + c];

			sum += color * kernelValue;
			sumKernel += kernelValue;
		}

		ImgOut[3 * row * width + 3 * col + c] = sum / sumKernel;
	}
}