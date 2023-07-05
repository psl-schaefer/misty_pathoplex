
### Usage ###
# Rscript scripts/concat_views.R "10_micron" "constant" "20" "" ""
# Rscript scripts/concat_views.R "1_micron" "gaussian" "15" "" "80"

### Packages ###
library(tidyverse)
library(mistyR)
here::i_am("scripts/concat_views.R")
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
# config_string <- "10_micron_constant_20__"
# config_string <- "1_micron_gaussian_15__80

### Load all views
file_data <- readRDS(here::here(processed_data_dir, "file_data.RDS"))
in_file <- paste0(processed_data_dir, .Platform$file.sep, "all_views_", config_string, ".RDS")
print(paste0("Reading views from: ", in_file))
all_views <- readRDS(in_file)
name_paraview_long <- grep("para.+", names(all_views[[1]]), value=TRUE)

### Define empty vec to start loop
l_init <- vector(mode="list", length=2)
names(l_init) <- c("intraview", name_paraview_long)

### Concat the global views
concat_views <- purrr::reduce(all_views, function(current_img, next_img) {

  l = list(intraview = rbind(current_img[["intraview"]], next_img[["intraview"]]$data))
  l[[name_paraview_long]] <- rbind(current_img[[name_paraview_long]], next_img[[name_paraview_long]]$data)
  l
}, .init = l_init)

print(purrr::map(concat_views, ~ dim(.x)))
colnames(concat_views[[name_paraview_long]]) <- str_remove(colnames(concat_views[[name_paraview_long]]), "p_")

out_file <- paste0(processed_data_dir, .Platform$file.sep, "concat_views_", config_string, "_global.RDS")
print(paste0("Saving concatenated views in: ", out_file))
saveRDS(concat_views, out_file)

### Concat the views per group_new (DKD vs Non-DKD)
for (group_oi in unique(file_data$group_new)) {
  print(group_oi)
  
  files_oi <- file_data %>%
    dplyr::filter(group_new %in% group_oi) %>%
    dplyr::pull(filename)
  
  concat_views <- purrr::reduce(all_views[names(all_views) %in% files_oi], function(current_img, next_img) {
    
    l = list(intraview = rbind(current_img[["intraview"]], next_img[["intraview"]]$data))
    l[[name_paraview_long]] <- rbind(current_img[[name_paraview_long]], next_img[[name_paraview_long]]$data)
    l
    
  }, .init = l_init)
  print(purrr::map(concat_views, ~ dim(.x)))
  colnames(concat_views[[name_paraview_long]]) <- str_remove(colnames(concat_views[[name_paraview_long]]), "p_")
  
  out_file <- paste0(processed_data_dir, .Platform$file.sep, "concat_views_", config_string, "_", group_oi, ".RDS")
  print(paste0("Saving concatenated views in: ", out_file))
  saveRDS(concat_views, out_file)
}