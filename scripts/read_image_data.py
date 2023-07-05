
import imageio.v3 as iio
import numpy as np
import os

# check R input
assert r.bin_len
print(f"{r.bin_len=}")
assert r.data_dir
print(f"{r.data_dir=}")
assert r.pixel_size
print(f"{r.pixel_size=}")

# load the png files
images = {}
for file in os.scandir(f"{r.data_dir}/images_clustered_uncolored"):
    im = iio.imread(f"{r.data_dir}/images_clustered_uncolored/{file.name}")
    images[file.name] = im
    
# get unique cell types
cluster_types = []
for image in images.values():
    cluster_types.append(np.unique(image))
cluster_types = np.unique(np.array(cluster_types))

# check whether all cell types are present
all(cluster_types == list(range(len(cluster_types))))

# determine the pixel size
p_size = int(np.ceil(r.bin_len / r.pixel_size))
print(f"Number of pixels per spot: {p_size}")

# read in all the images and prepare the matrices.
coords_imgs = {}
cluster_counts_imgs = {}
sizes_imgs = {}
for k, im in images.items():
    sizes_imgs[k] = im.shape
    nrows = int(np.ceil(im.shape[0] / p_size))
    ncols = int(np.ceil(im.shape[1] / p_size))
    n_spots = nrows * ncols

    coords = np.zeros((n_spots, 2)).astype(np.uint16)
    cluster_counts = np.zeros((n_spots, len(cluster_types))).astype(np.uint16)

    for i in range(nrows):
        for j in range(ncols):
            # bin number
            bin_num = (i*ncols) + j
    
            # take care of coordinates
            coords[ bin_num, : ] = np.array([ (p_size/2) + i*p_size, (p_size/2) + j*p_size ])
        
            # take care of cluster counts
            xmin, xmax = i*p_size, (i+1)*p_size
            ymin, ymax = j*p_size, (j+1)*p_size
    
            # take care of edge cases
            xmax = min(xmax, im.shape[0])
            ymax = min(ymax, im.shape[1])
    
            # count the cluster instances
            counts_i  = np.unique(im[xmin:xmax, ymin:ymax].flatten(), return_counts=True)
            cluster_counts[bin_num, counts_i[0]] = counts_i[1]

    coords_imgs[k] = coords
    cluster_counts_imgs[k] = cluster_counts
    
      
# free memory
del images
