# Global-Metabolomics-Pipeline
## Global metabolomics data process pipeline
This project is to build a pipeline to process data after xcms preprocessing, then perform the MS1 and MS2 library search for annotation.


## Usage
1. Clone this repo:
   ```bash
   git clone https://github.com/fyang22/Global-Metabolomics-Pipelines.git
   ```
2. Install R dependencies:
   ```bash
   Scripts/00_setup.R
   ```
3. Run scripts sequentially:
   ```bash
   # convert xcms output feature list to SERRF input format.
   Scripts/01_convert_to_SERRF.R
   # combine normalized features after SERRF to xcms output
   Scripts/01b_combine_SERRF_XCMS.R
   # precursor masses match with HMDB database
   Scripts/02_ms1_match.R
   # ms/ms spectra match with experimental mass spectra, e.g mona, inhouse library
   Scripts/03_ms2_match.R 
   # Boxplot
   Scripts/04_boxplot.R
   ```

## data

### add raw mzml data and feature tables
- raw: "data/raw/" 
  - mzML files: precursor mass corrector after MS convertor if it needed (https://github.com/elnurgar/mzxml-precursor-corrector)
- xcms_SERRF: "data/xcms_SERRF/" 
  - "XCMS_full.csv": Result from XCMS preprocessing as input table for script-01  
  - "normalized by - SERRF.csv" Result from SERRF normalized file as input table for script-01b
### HMDB table  
- "data/hmdb_cleanup_v02062023.csv": Precursor masses search in HMDB metabolites table for script-02
### add Metaboanalyst results 
- Metaboanalyst: "data/Metaboanalyst": Results from metaboanalyst with significant features list for boxplot script-04

## Output

### XCMS feature clean up data
- Tables: "output/xcms_SERRF/
  - "SERRF_input.csv": converted xcms file for SERRF normalization 
  - "XCMS_full_normalized.csv"("XCMS_full_normalized_noQC.csv"): updata xcms features with SERRF noramlization (without QC) 

### MS output data
- Tables: "output/"
  - MS matches with HMDB: "ms1mtch_hmdb_features.csv"
  - MS2 matches with DB: "list_features_ms2.csv"
  - MS/MS matched results: "output/db/"
    - MS2 matches with database: "ms2mtch_FeatureName.csv"

- Tables: "output/Metaboanalyst_input/" : 
  - Combine features for MetaboAnalyst (without QC)
    - "MetaboAnalyst_features.csv"
    - "MetaboAnalyst_features_noQC.csv"
  - Combine features with labels for MetaboAnalyst (without QC)
    - "MetaboAnalyst_withLabel.csv"
    - "MetaboAnalyst_withLabel_noQC.csv"
  - Feature list for boxplot: "boxplot.csv"

### Figures
- Boxplot for the selected features: "output/plot"

  
## Reproducibility
- R version: See "session_info.txt"
- Dependencies: See "session_info.txt"; Scripts/00_setup.R
  