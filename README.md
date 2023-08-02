
# misty_pathoplex

## Notes

- First install mistyR from BioConductor: `BiocManager::install("mistyR")`

- Then install ridge package from Github: `devtools::install_github("https://github.com/schae211/ridge", force=TRUE)`

- The original ridge package has some performance ploblems when computing pvalues, see here: https://github.com/SteffenMoritz/ridge/pull/21

- Check whether you are using the correct version by looking at the function: `ridge:::pvals.ridgeLinear`

## Project Description

Collaboration with Malte Kuehl from the Victor Puelles group.

Pathoplex Dataset: Glomeruli from CKD (9 patients), Non-CKD (9 patients), Diabetic-Nephropathy (20 patients). Metadata such as EGFR, age, ckd-stage, sex is available.

## Method Description

Condition-specific structural patterns were identified with MISTy (mistyR v1.6.1). To that end, we first aggregated the image data (112 images for DKD and 310 for non-DKD) at two different resolutions by summing up the cluster counts in bins with a side length of 1 micrometer (62 x 62 pixels) or 10 micrometers (6 x 6 pixels). The unspecific clusters (4, 5, 8, 10, 16, 23, 27, 29, 30, 33, 34, 35, 36, 38, 40, 42, 43, 45, 46) were collapsed into a single cluster. To account for truncated bins at the edges of slides, we transformed the counts into proportions.

We used these cluster proportions per bin as an intrinsic representation of the structure within a bin (MISTy intraview). To capture the broader tissue structure, we constructed the paraview by summing up the cluster proportions of the 20 nearest neighbors using family=”constant”, l=20. To construct the paraview for the high-resolution aggregation, we computed the weighted sum of the cluster proportions of the 80 nearest neighbors using a Gaussian kernel with a bandwidth of 2.5 micrometers (corresponding to 15.2 pixels) (family=”gaussian”, l=15.2, nn=80). With these view compositions per aggregation,  a MISTy model was trained for each sample independently. The MISTy models identify significant structural patterns in the different spatial contexts by associating the proportion of pixels belonging to each cluster in each spatial context to the target proportions in the intraview.

MISTy can learn not only simple linear relationships (e.g. cluster X has a higher proportion if cluster Y has a lower proportion"), but also complex non-linear relationships.By combining the predictions from the intra- and paraview for each cluster, MISTy allows us to disentangle whether the prediction for a given cluster improves, and to what extent, when taking different spatial contexts into account.

To compare the MISTy importance scores between DKD and non-DKD patients we first computed the mean results per sample due to differing numbers of glomeruli. We then aggregated the MISTy results per patient and finally per condition (DKD and non-DKD). For each level of aggregation, group, and view we generated a graph representing the inferred relationships between clusters. In each graph the nodes represent the clusters and the edges between the clusters are weighted by the importance scores inferred by the MISTy model (thresholded to conserve only significant relationships – importance >= 0.8). Subsequently, we identified community structures within the graph. To this end we used the Leiden algorithm with resolution set to 1. To visualize the graphs, we set the width of the edges proportional to the importance scores, and the color of edges according to the correlation between different clusters across all bins in a given aggregation level, view, and group.

## Pipeline

1) Load image data

`Rscript scripts/load_image_data.R`

2) Compute views (here)

`Rscript scripts/get_views.R "10_micron" "constant" "20" "" ""`
`Rscript scripts/get_views.R "1_micron" "gaussian" "15.2" "" "80"`

3) Run misty

`Rscript scripts/run_misty.R "10_micron" "constant" "20" "" ""`
`Rscript scripts/run_misty.R "1_micron" "gaussian" "15.2" "" "80"`

4) Load misty results

`Rscript scripts/load_misty_results.R "10_micron" "constant" "20" "" ""`
`Rscript scripts/load_misty_results.R "1_micron" "gaussian" "15.2" "" "80"`

5) Concatenate views

`Rscript scripts/concat_views.R "10_micron" "constant" "20" "" ""`
`Rscript scripts/concat_views.R "1_micron" "gaussian" "15.2" "" "80"`

6) Generate report

`Rscript scripts/get_report.R "10_micron" "constant" "20" "" ""`
`Rscript scripts/get_report.R "1_micron" "gaussian" "15.2" "" "80"`

7) Export misty results

`Rscript scripts/export_data.R`
