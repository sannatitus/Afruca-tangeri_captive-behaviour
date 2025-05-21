## Requirements for Running the R Script

To run this R script successfully, **R version 4.0.0 or higher** is recommended.

### Required R Packages

The following R packages are used:
- `readxl`
- `dplyr`
- `vegan`
- `DirichletReg`
- `car`
- `ggplot2`
- `tidyr`
- `lubridate`

To install all required packages, run:

```r
install.packages(c(
  "readxl", "dplyr", "vegan", "DirichletReg", "car", "ggplot2", "tidyr", "lubridate"
))
```

---

### Session Information

Here is the session info used to generate the published statistics:

```
R version 4.4.2 (2024-10-31 ucrt)
Platform: x86_64-w64-mingw32/x64
Running under: Windows 10 x64 (build 19045)

Matrix products: default

locale:
[1] LC_COLLATE=English_United Kingdom.utf8 
[2] LC_CTYPE=English_United Kingdom.utf8   
[3] LC_MONETARY=English_United Kingdom.utf8
[4] LC_NUMERIC=C
[5] LC_TIME=English_United Kingdom.utf8    

time zone: Europe/London
tzcode source: internal

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base

other attached packages:
 [1] lubridate_1.9.3    ggplot2_3.5.1      car_3.1-3          carData_3.0-5
 [5] tidyr_1.3.1        DirichletReg_0.7-1 Formula_1.2-5      vegan_2.6-10
 [9] lattice_0.22-6     permute_0.9-7      dplyr_1.1.4        readxl_1.4.5

loaded via a namespace (and not attached):
 [1] Matrix_1.7-1     gtable_0.3.6     jsonlite_1.8.9   compiler_4.4.2
 [5] tidyselect_1.2.1 parallel_4.4.2   cluster_2.1.6    scales_1.3.0
 [9] splines_4.4.2    R6_2.5.1         maxLik_1.5-2.1   generics_0.1.3
[13] MASS_7.3-65      tibble_3.2.1     munsell_0.5.1    pillar_1.9.0
[17] rlang_1.1.4      utf8_1.2.4       timechange_0.3.0 cli_3.6.3
[21] withr_3.0.2      magrittr_2.0.3   mgcv_1.9-1       digest_0.6.37
[25] grid_4.4.2       sandwich_3.1-1   lifecycle_1.0.4  nlme_3.1-166
[29] miscTools_0.6-28 vctrs_0.6.5      glue_1.8.0       cellranger_1.1.0
[33] zoo_1.8-12       abind_1.4-8      colorspace_2.1-1 fansi_1.0.6
[37] purrr_1.0.2      tools_4.4.2      pkgconfig_2.0.3
```
