
### Usage ###
# Rscript scripts/export_data.R

here::i_am("scripts/export_data.R")

source(here::here("config.R"))
source(here::here("scripts", "utils.R"))
file_data <- readRDS(here::here("processed_data", "file_data.RDS"))

name_to_config <- list("10_micron" = "10_micron_constant_20__", 
                       "1_micron" = "1_micron_gaussian_2.5__80")
purrr::iwalk(name_to_config, function(config_string, resolution_name) {
   # config_string = "10_micron_constant_20__"; resolution_name="10_micron"
   print(config_string)  
   print(resolution_name)
   in_file <- paste0(processed_data_dir, .Platform$file.sep, "all_views_", config_string, ".RDS")
   print(paste0("Reading views from: ", in_file))
   all_views <- readRDS(in_file)
   
   results <- readRDS(here::here(misty_dir, paste0( "global_", config_string, ".RDS")))
   name_paraview <- grep("para.+", unique(results$importances$view), value=TRUE)
   name_paraview_long <- grep("para.+", names(all_views[[1]]), value=TRUE)
   rm(all_views); gc()
   
   # check if we are loading the correct things here
   results.groups <- readRDS(here::here(misty_dir, paste0("DKD_non-DKD_", 
                                                          config_string, ".RDS")))
   groups <- names(results.groups)
   
   purrr::walk(groups, function(group) {
     # group = "Control"
     
     results.groups[[group]]$importances <- results.groups[[group]]$importances %>%
       dplyr::mutate(Predictor = str_remove(Predictor, "^p_"))
     
     # first compute the mean importances per patient, then aggregate
     results.groups[[group]]$importances.aggregated <- 
       results.groups[[group]]$importances %>%
       dplyr::mutate(sample=basename(sample)) %>%
       dplyr::left_join(file_data %>% dplyr::select(filename, unique_patient_id),
                        by=c("sample" = "filename")) %>%
       dplyr::group_by(view, Predictor, Target, unique_patient_id) %>%
       dplyr::summarise(Importance = mean(Importance), .groups = "drop_last") %>%
       dplyr::summarise(Importance = mean(Importance), nsamples = n(), .groups = "drop")
     
     # get the concatenated views
     concat_views_oi <- readRDS(paste0(processed_data_dir, .Platform$file.sep, "concat_views_", config_string, "_", group, ".RDS"))
     
     community_detection_configs <- list(list("view.short"="intra", "view.long"="intraview", "file.name"="intra"), 
                                         list("view.short"=name_paraview, "view.long"=name_paraview_long, "file.name"="para"))
     
     purrr::walk(community_detection_configs, function(view_config) {
         # view_config = list(view.short="intra", view.long="intraview", file.name="intra")
         out_graph <- interaction_communities_info_no_clust(misty.results=results.groups[[group]], 
                                                            concat.views=concat_views_oi, 
                                                            view.short=view_config$view.short, 
                                                            view.long=view_config$view.long,
                                                            cutoff=0)
         out_df <- igraph::as_data_frame(out_graph, what="edges") %>%
           dplyr::rename("Importance" = "weight",
                         "Predictor" = "from",
                         "Target" = "to")
         out_file <- paste0(resolution_name, "_", group, "_", str_remove(view_config$view.short, "\\.[0-9]+$"), ".csv")
         print(paste0("Writing output to ", out_file))
         write_csv(out_df, here::here(export_dir, out_file))
         })
     }) 
   })
