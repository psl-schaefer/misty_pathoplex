
### Usage ###
# Rscript scripts/run_misty.R "1_micron" "gaussian" "2.5" "" "80"
# Rscript scripts/run_misty.R "10_micron" "constant" "20" "" ""

### Packages ###
library(tidyverse)
library(mistyR)
library(future)
#cores <- future::availableCores()-1
cores <- 20 # got some future problems with loosing connection to workers
plan(strategy="multicore", workers=cores)
print(paste0("Using ", cores, " cores"))

source(here::here("config.R"))
here::i_am("scripts/run_misty.R")
recompute <- TRUE

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

misty_out <- here::here(misty_dir, config_string)
dir.create(misty_out, showWarnings = FALSE)

in_file <- paste0(processed_data_dir, .Platform$file.sep, "all_views_", bin_name, 
                  "_", family, "_", l, "_", prefix, "_", nn, ".RDS")
print(paste0("Reading views from: ", in_file))
all_views <- readRDS(in_file)

purrr::iwalk(all_views, function(misty.views, img_name) {
  if ((!img_name %in% list.files(misty_out)) | recompute) {
    run_misty(views = misty.views, 
              results.folder = paste0(misty_out, .Platform$file.sep, img_name))
  } else {
    print(paste0(img_name, " was computed previously"))
  }
})