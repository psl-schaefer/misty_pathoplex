
### configs ###

# data directory
data_dir <- here::here("dkd_data")

# processed data directory
processed_data_dir = here::here("processed_data")
dir.create(processed_data_dir, showWarnings = FALSE)

# misty output directory
misty_dir = here::here("misty_results")
dir.create(misty_dir, showWarnings = FALSE)

# export data directory
export_dir = here::here("exported_data")
dir.create(export_dir, showWarnings = FALSE)

# export data directory
report_dir = here::here("reports")
dir.create(report_dir, showWarnings = FALSE)

# specify size of a single pixel
pixel_size <- 162.4

# specify side length of bins in nano meter; TODO: fix this
bin_lengths <- list("10_micron" = 10000, "1_micron" = 1000)

# all clusters
all_clusters <- as.character(seq(0, 46))
unspecific_clusters <-  as.character(c(4, 5, 8, 10, 16, 23, 27, 29, 30, 33, 34, 35, 36, 38, 40, 42, 43, 45, 46))
specific_clusters <- dplyr::setdiff(all_clusters, unspecific_clusters)

# Name for the unspecific clusters
c_name_unspecific <- "unspec"

# Which possibilities do we have to deal with unspecific clusters
features <- list(
  # leave in
  "A" = all_clusters,
  # exclude
  "B" = specific_clusters,
  # group
  "C" = c(specific_clusters, c_name_unspecific)
)

# Option chosen for current analysis
feat <- features$C
