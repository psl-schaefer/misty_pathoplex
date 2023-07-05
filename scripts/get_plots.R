
### Usage ###
# Rscript scripts/get_plots.R "10_micron" "constant" "20" "" ""
# Rscript scripts/get_plots.R "1_micron" "gaussian" "15" "" "80"

### Packages ### 
library(tidyverse)
library(mistyR)
library(factoextra)
library(igraph)
here::i_am("scripts/load_misty_results.R")
source(here::here("config.R"))

### CMD ARGS ###
args = commandArgs(trailingOnly=TRUE)
bin_name <- args[1]
family <- args[2]
l <- as.numeric(args[3])
prefix <- args[4]
nn <- if (args[5]=="") NULL else as.numeric(args[5])
config_string <- paste0(bin_name, "_", family, "_", l, "_", prefix, "_", nn)

### verbosity ###
print(paste0("bin_name: ", bin_name, " ", class(bin_name)))
print(paste0("family: ", family, " ", class(family)))
print(paste0("l: ", l, " ", class(l)))
print(paste0("prefix: ", prefix, " ", class(prefix)))
print(paste0("nn: ", nn, " ", class(nn))) 
print(paste0("config string: ", config_string))

source(here::here("config.R"))
source(here::here("scripts", "utils.R"))
dir.create(here::here("plots", config_string), showWarnings = FALSE, recursive = TRUE)

### load processed data ###
file_data <- readRDS(here::here("processed_data", "file_data.RDS"))
coords <- readRDS(here::here("processed_data", paste0("coords_", bin_name, ".RDS")))
cluster_counts <- readRDS(here::here("processed_data", paste0("cluster_counts_", bin_name, ".RDS")))
all(names(coords) == names(cluster_counts)) # check
img_names <- names(cluster_counts)

# Stratify clusters based on whether they are specific or unspecific (see Mail by Malte).
stopifnot(all(sort(c(unspecific_clusters, specific_clusters)) == sort(all_clusters)))

# Prepare indexing by character. The clusters are names from 0 to 46 which is convenient in Python (0-based indexing), 
# but annoying in R (1-based indexing). So I will just index by character.
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

in_file <- paste0(processed_data_dir, .Platform$file.sep, "all_views_", config_string, ".RDS")
print(paste0("Reading views from: ", in_file))
all_views <- readRDS(in_file)

### Global results ###
