# Afruca-tangeri_captive-behaviour

Raw data and analysis pipeline for West African fiddler crab (*Afruca tangeri*) behaviour in captive environments. Last updated by Sanna Titus, sannatitus@yahoo.com, May 2025 

---

## Folder Structure

### `/Data`
- Contains the raw instantaneous behaviour data acquisition csv, which includes all variables statistically analysed (e.g., `video file`, `crab ID`, `day type`, `minimum lifespan`, etc.) and concatenated 'non visibility' entries. 

### `/Analysis`
- **Python scripts** for:
  - Data cleaning
  - Data validation
  - Calculation of non-visibility backtracking
  - Descriptive statistics
  - Chi-square statistics on the probability of visibility
  - Figure generation
- **Requirements:**  
  - Package and version requirements for reproducing the Python pipeline are provided.
- **R script** for:
  - Formal statistical analysis (univariate and multivariate PERMANOVAs, Dirilecht regression, Redundancy Analysis); see `/Analysis/statistics_permanova-dirilecht-RDA.R`
- **Requirements:**  
  - Package and version requirements for reproducing the R pipeline are provided.

### `/Figures`
- All main and supplementary figures available in the article.
- Text files for specific statistical analysis outputs from R (e.g., univariate and multivariate PERMANOVAs, Dirilecht regression, Redundancy Analysis).

---

## Reproducibility

- See `/Analysis/requirements_Python.txt` and `/Analysis/requirements_R.txt` for package and version details.

---

## Contact

For questions or collaboration, please contact Sanna at sannatitus@yahoo.com. 
