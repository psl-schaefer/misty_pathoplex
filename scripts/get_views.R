
### Usage ###
# Rscript scripts/get_views.R "10_micron" "constant" "20" "" ""
# Rscript scripts/get_views.R "1_micron" "gaussian" "2.5" "" "80"

### Packages ###
library(tidyverse)
library(mistyR)
library(future)
cores <- future::availableCores()-1
plan(strategy="multicore", workers=cores)
print(paste0("Using ", cores, " cores"))

source(here::here("config.R"))
here::i_am("scripts/get_views.R")

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

file_data <- readRDS(here::here(processed_data_dir, "file_data.RDS"))
coords <- readRDS(paste0(processed_data_dir, .Platform$file.sep, "coords_", bin_name, ".RDS"))
cluster_counts <- readRDS(paste0(processed_data_dir, .Platform$file.sep, "cluster_counts_", bin_name, ".RDS"))
all(names(coords) == names(cluster_counts)) # check
img_names <- names(cluster_counts)

all_views <- img_names %>% 
  purrr::set_names(img_names) %>%
  purrr::map(function(img_name) {
    
    # get the right coordinates
    coord <- as_tibble(coords[[img_name]]) %>%
      purrr::set_names(c("x", "y"))
    
    # get the cluster counts and normalize
    # Prepare indexing by character. The clusters are names from 0 to 46 which is convenient in Python (0-based indexing),
    # but annoying in R (1-based indexing). So I will just index by character
    cluster_count <- as_tibble(cluster_counts[[img_name]]) %>%
      purrr::set_names(all_clusters) %>%
      dplyr::mutate(!!c_name_unspecific := rowSums(.[, unspecific_clusters])) %>%
      dplyr::select(all_of(feat)) %>%
      dplyr::mutate(across(everything())/rowSums(across(everything())))
    
    # fix names
    colnames(cluster_count) <- paste0("c_", colnames(cluster_count))
    
    # create misty views
    misty.intra <- create_initial_view(cluster_count)
    misty.views <- misty.intra %>% add_paraview(coord, family=family, l=l, prefix=prefix, nn=nn)
    
    return(misty.views)
  })

out_file <- paste0(processed_data_dir, .Platform$file.sep, "all_views_", bin_name, 
                   "_", family, "_", l, "_", prefix, "_", nn, ".RDS")
print(paste0("Saving views as: ", out_file))
saveRDS(all_views, out_file)
