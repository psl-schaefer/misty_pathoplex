
here::i_am("scripts/load_image_data.R")

suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(reticulate))

# check on which system we are running
if (Sys.info()["sysname"] == "Darwin") use_condaenv("misty4i")
if (Sys.info()["sysname"] == "Linux") use_condaenv("r-reticulate")

source(here::here("config.R"))

# you cannot use purrr::walk here, we need bin_len, bin_name in global env
for (idx in seq_len(length(bin_lengths))) {
  
  bin_len = bin_lengths[[idx]]
  bin_name = names(bin_lengths)[idx]
  # provide r.bin_len
  # provide r.data_dir
  # provide r.pixel_size
  reticulate::source_python(here::here("scripts", "read_image_data.py"))
  
  saveRDS(py$coords_imgs, paste0(processed_data_dir, .Platform$file.sep, "coords_", bin_name, ".RDS"))

  saveRDS(py$sizes_imgs, paste0(processed_data_dir, .Platform$file.sep, "image_sizes.RDS"))
  
  saveRDS(py$cluster_counts_imgs, paste0(processed_data_dir, .Platform$file.sep, "cluster_counts_", bin_name, ".RDS"))
}

meta_data <- read_csv(here::here(data_dir, "clinical_data_dkd_with_patient_id.csv"),
                      show_col_types = FALSE)

file_data <- tibble(filename = list.files(here::here(data_dir, "images_clustered_uncolored"))) %>%
  dplyr::mutate(plate = as.numeric(str_extract(filename, "(?<=Plate_)[0-9]+"))) %>%
  dplyr::mutate(image = str_extract(filename, "(?<=Image_)[0-9A-Z]+")) %>%
  dplyr::mutate(position = as.numeric(str_extract(filename, "(?<=Position_)[0-9]+")))

file_data <- file_data %>%
  dplyr::left_join(meta_data,
                   by=c("plate"="plate", "image"="well"))

file_data <- file_data %>%
  dplyr::left_join(purrr::imap_dfr(readRDS(here::here(processed_data_dir, "image_sizes.RDS")), 
                                   ~ tibble(filename=.y, x_size=.x[[1]], y_size=.x[[2]])),
                   by="filename") %>%
  dplyr::mutate(size = paste0(x_size, " x ", y_size))

new_groups <- list("Control" = c("CKD", "Non-CKD"), 
                   "Diabetic-Nephropathy" = "Diabetic-Nephropathy")

file_data <- file_data %>%
  dplyr::mutate(group_new = ifelse(group %in% c("CKD", "Non-CKD"), "Control", "Diabetic-Nephropathy"))

saveRDS(file_data, here::here(processed_data_dir, "file_data.RDS"))
