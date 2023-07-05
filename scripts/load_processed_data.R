
here::here("scripts/load_processed_data")

library(tidyverse)

file_data <- readRDS(here::here("processed_data", "file_data.RDS"))
coords <- readRDS(here::here("processed_data", paste0("coords_", bin_name, ".RDS")))
cluster_counts <- readRDS(here::here("processed_data", paste0("cluster_counts_", bin_name, ".RDS")))
all(names(coords) == names(cluster_counts)) # check
img_names <- names(cluster_counts)

# Stratify clusters based on whether they are specific or unspecific (see Mail by Malte).

all_clusters <- as.character(seq(0, ncol(cluster_counts[[1]])-1))
unspecific_clusters <-  as.character(c(4, 5, 8, 10, 16, 23, 27, 29, 30, 33, 34, 35, 36, 38, 40, 42, 43, 45, 46))
specific_clusters <- dplyr::setdiff(all_clusters, unspecific_clusters)

# check
stopifnot(all(
  sort(c(unspecific_clusters, specific_clusters)) == sort(all_clusters)
))

# Prepare indexing by character. The clusters are names from 0 to 46 which is convenient in Python (0-based indexing), but annyoing in R (1-based indexing). So I will just index by character.

for (img_name in names(cluster_counts)) {
  # take care of cluster counts
  mtx <- cluster_counts[[img_name]]
  colnames(mtx) <- all_clusters
  cluster_counts[[img_name]] <- mtx
  
  # take care of coordinates
  c_mtx <- coords[[img_name]]
  colnames(c_mtx) <- c("x", "y")
  coords[[img_name]] <- c_mtx
}

# checks
#cluster_counts[[1]][0:2, 0:6]
#coords[[0]][0:2, ]