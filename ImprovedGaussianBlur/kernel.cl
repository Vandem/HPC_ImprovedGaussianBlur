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
	int globalId = get_global_id(0);
	int pixel = get_local_id(0);
	int workGroupId = get_group_id(0);
	int workGroupSize = get_num_groups(0);

	int diameter = radius * 2 + 1;

	if (globalId == 0) {
		printf("radius: %d \n", radius);
		printf("diameter: %d \n", diameter);
	}

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
	if (pixel == 0)
	{
		for (int i = 0; i < limit; i++) {
			for (int c = 0; c < 3; c++) {
			if (orientation == 1) // row-wise
				partition[i * 3 + c] = ImgIn[3 * row * width + 3 * i + c];
			else // col-wise
				partition[i * 3 + c] = ImgIn[3 * i * width + 3 * col + c];
			}
		}
	}

	barrier(CLK_LOCAL_MEM_FENCE);

	for (int c = 0; c < 3; c++)
	{
		float sum = 0;
		float sumKernel = 0;

		for (int x = -radius; x <= radius; x++)
		{
			float kernelValue = GaussKernel[x + radius];

			int currentPixel = pixel;

			if ((pixel + x) >= 0 && (pixel + x) < limit)
			{
				currentPixel += x;
			}

			float color = partition[currentPixel * 3 + c];
			sum += color * kernelValue;
			sumKernel += kernelValue;
		}

		ImgOut[3 * row * width + 3 * col + c] = sum / sumKernel;
	}
}