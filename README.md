
# misty_pathoplex

## Notes

- First install mistyR from BioConductor: `BiocManager::install("mistyR")`

- Then install ridge package from Github: `devtools::install_github("https://github.com/schae211/ridge", force=TRUE)`

- The original ridge package has some performance ploblems when computing pvalues, see here: https://github.com/SteffenMoritz/ridge/pull/21

- Check whether you are using the correct version by looking at the function: `ridge:::pvals.ridgeLinear`

## Project Description

Collaboration with Victor Puelles (and postdoc in the lab: Malte Kuehl).

Dataset 1: Glomeruli from CKD (9 patients), Non-CKD (9 patients), Diabetic-Nephropathy (20 patients). Metadata such as EGFR, age, ckd-stage, sex is available.

## Method Description

To run MISTy, we first aggregated the data at two different resolutions by summing up the cluster counts in bins with a side length of 1 micrometer (62 x 62 pixels) or 10 micrometers (6 x 6 pixels). The unspecific clusters (4, 5, 8, 10, 16, 23, 27, 29, 30, 33, 34, 35, 36, 38, 40, 42, 43, 45, 46) were collapsed into a single cluster. To account for truncated bins at the edges of slides, we transformed the counts into proportions.

We used these cluster proportions per bin as MISTy intraview. For both levels of aggregation we constructed one paraview: For the low resolution aggregation, we constructed the paraview by summing up the cluster proportions of the 20 nearest neighbors using `add_paraview` with `family=”constant”` and `l=20`. To construct the paraview for the high resolution aggregation, we computed the weighted sum of the cluster proportions of the 80 nearest neighbors using a Gaussian kernel with a bandwidth of 2.5 micrometers (corresponding to 15.2 pixels) (`add_paraview` with `family=”gaussian”`, `l=15.2`, and `nn=80`). We then used the default settings to run the MISTy model.

To analyze the results we first summarized the results per patient, because a different number of glomeruli was measured for each patient.

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
