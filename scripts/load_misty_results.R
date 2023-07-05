
### Usage ###
# Rscript scripts/load_misty_results.R "10_micron" "constant" "20" "" ""
# Rscript scripts/load_misty_results.R "1_micron" "gaussian" "15" "" "80"

### Packages ### 
library(tidyverse)
library(mistyR)
library(future)

cores <- 20 # got some future problems with loosing connection to workers
plan(strategy="multicore", workers=cores)
print(paste0("Using ", cores, " cores"))

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

file_data <- readRDS(here::here(processed_data_dir, "file_data.RDS"))
misty_out <- here::here(misty_dir, config_string)
print(misty_out)

# global
misty_res <- collect_results(list.files(misty_out, full.names = TRUE))
saveRDS(misty_res, file=here::here(misty_dir, paste0( "global_", config_string, ".RDS")))

# new grouping asked for my Malte
results <- unique(file_data$group_new) %>%
  purrr::set_names() %>%
  purrr::map(function(g) {
    result_folders <- 
      here::here(misty_dir, config_string,
                 (file_data %>% dplyr::filter(group_new %in% g) %>% dplyr::pull(filename)))
    print(g)
    print(length(result_folders))
    return(mistyR::collect_results(folders=result_folders))
  })
saveRDS(results, file=here::here(misty_dir, paste0("DKD_non-DKD_", config_string, ".RDS")))
