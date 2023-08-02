
library(igraph)
library(tidyverse)

interaction_communities_info <- function(misty.results, concat.views, 
                                         view.short, view.long,
                                         cutoff = 1, res = 1) {
  
  view.wide <- misty.results$importances.aggregated %>%
    dplyr::filter(view == !!view.short) %>%
    tidyr::pivot_wider(
      names_from = "Target", values_from = "Importance",
      id_cols = -c(view, nsamples)
    )
  
  assertthat::assert_that(
    all((view.wide %>%
           dplyr::select(-Predictor) %>% colnames() %>% sort()) ==
          (view.wide %>%
             dplyr::pull(Predictor)) %>% sort()),
    msg = "The predictor and target markers in the view must match."
  )
  
  assertthat::assert_that(requireNamespace("igraph", quietly = TRUE),
                          msg = "The package igraph is required to calculate the interaction communities."
  )
  
  A <- view.wide %>%
    dplyr::select(-Predictor) %>%
    as.matrix()
  A[A < cutoff | is.na(A)] <- 0
  
  print(paste0("Number of considered interactions: ", sum(A != 0)))
  
  G <- igraph::graph.adjacency(A, mode = "plus", weighted = TRUE) %>%
    igraph::set.vertex.attribute("name", value = names(igraph::V(.))) %>%
    igraph::delete.vertices(which(igraph::degree(.) == 0))
  
  Gdir <- igraph::graph.adjacency(A, "directed", weighted = TRUE) %>%
    igraph::set.vertex.attribute("name", value = names(igraph::V(.))) %>%
    igraph::delete.vertices(which(igraph::degree(.) == 0))
  
  C <- igraph::cluster_leiden(G, n_iterations=-1, resolution_parameter = res)
  
  mem <- igraph::membership(C)
  
  Gdir <- igraph::set_vertex_attr(Gdir, "community", names(mem), as.numeric(mem))
  
  corrs <- as_edgelist(Gdir) %>% apply(1, \(x) cor(concat.views[["intraview"]][,x[1]], 
                                                   concat.views[[view.long]][,x[2]])) 
  Gdir <- set_edge_attr(Gdir, "cor", value = corrs)
  
  print(paste0("Number of communities: ", length(unique(igraph::get.vertex.attribute(Gdir)$community))))
  
  return(Gdir)
}

interaction_communities_info_no_clust <- function(misty.results, concat.views, 
                                                  view.short, view.long,
                                                  cutoff = 0) {
  
  view.wide <- misty.results$importances.aggregated %>%
    dplyr::filter(view == !!view.short) %>%
    tidyr::pivot_wider(
      names_from = "Target", values_from = "Importance",
      id_cols = -c(view, nsamples)
    )
  
  assertthat::assert_that(
    all((view.wide %>%
           dplyr::select(-Predictor) %>% colnames() %>% sort()) ==
          (view.wide %>%
             dplyr::pull(Predictor)) %>% sort()),
    msg = "The predictor and target markers in the view must match."
  )
  
  assertthat::assert_that(requireNamespace("igraph", quietly = TRUE),
                          msg = "The package igraph is required to calculate the interaction communities."
  )
  
  A <- view.wide %>%
    dplyr::select(-Predictor) %>%
    as.matrix()
  A[A < cutoff | is.na(A)] <- 0
  
  print(paste0("Number of considered interactions: ", sum(A != 0)))
  
  G <- igraph::graph.adjacency(A, mode = "plus", weighted = TRUE) %>%
    igraph::set.vertex.attribute("name", value = names(igraph::V(.))) %>%
    igraph::delete.vertices(which(igraph::degree(.) == 0))
  
  Gdir <- igraph::graph.adjacency(A, "directed", weighted = TRUE) %>%
    igraph::set.vertex.attribute("name", value = names(igraph::V(.))) %>%
    igraph::delete.vertices(which(igraph::degree(.) == 0))
  
  corrs <- as_edgelist(Gdir) %>% apply(1, \(x) cor(concat.views[["intraview"]][,x[1]], 
                                                   concat.views[[view.long]][,x[2]])) 
  Gdir <- set_edge_attr(Gdir, "cor", value = corrs)
  
  print(paste0("Number of communities: ", length(unique(igraph::get.vertex.attribute(Gdir)$community))))
  
  return(Gdir)
}

