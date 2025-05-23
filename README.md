# Afruca-tangeri_captive-behaviour

Raw data and analysis pipeline for West African fiddler crab (*Afruca tangeri*) behaviour in captive environments. Last updated by Sanna Titus, sannatitus@yahoo.com, May 2025 

---

## Folder Structure

### `/Data`
- Contains the raw instantaneous behaviour data acquisition xlsx and backup csv, which includes all variables statistically analysed (e.g., `video file`, `crab ID`, `day type`, `minimum lifespan`, etc.) and the first iteration of concatenated 'non visibility' entries from `validation.py`. For the entire concatenated 'NV' dataframe, please see df_total within `/Analysis/figures.py`
- **Python scripts** for:
  - Data acquisition selection of dates & observation windows; see `data-selection.py`
  - Data cleaning and duplicates check; see `validation.ipynb`
  - Data validation; see `validation.ipynb`

### `/Analysis`
- **Python script** `figures.ipynb` for:
  - Calculation of non-visibility backtracking
  - Descriptive statistics
  - Chi-square statistics on the probability of visibility
  - Figure generation
- **R script** `statistics_permanova-dirilecht-RDA.R` for:
  - Formal statistical analysis (univariate and multivariate PERMANOVAs, Dirilecht regression, Redundancy Analysis)

### `/Figures+Results`
- All main and supplementary figures available in the article.
- Text files for specific statistical analysis outputs from R (e.g., univariate and multivariate PERMANOVAs, Dirilecht regression, Redundancy Analysis).

### `/Environments`
- Package and version requirements for reproducing the Python pipeline are provided as `environment_Python.yaml`
- Package and version requirements for reproducing the R pipeline are provided as `environment_R.md`

---

## Contact

For questions or collaboration, please contact Sanna at sannatitus@yahoo.com. 
