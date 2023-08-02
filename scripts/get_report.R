#!/usr/bin/env Rscript

### Usage ###
# Rscript scripts/get_report.R "10_micron" "constant" "20" "" ""
# Rscript scripts/get_report.R "1_micron" "gaussian" "15" "" "80"

### CMD ARGS ###
args = commandArgs(trailingOnly=TRUE)
if (length(args)==0) {
  stop("no arguments supplied", call.=FALSE)
}
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

here::i_am("scripts/get_report.R")
source(here::here("config.R"))

rmarkdown::render(input=here::here("scripts", "report.Rmd"),
                  output_format = NULL, # use yaml header from file
                  output_file = paste0(config_string, "_report"),
                  output_dir = report_dir,
                  knit_root_dir = getwd(),
                  params = list("bin_name"=bin_name,
                                "family"=family,
                                "l"=l,
                                "prefix"=prefix,
                                "nn"=nn))