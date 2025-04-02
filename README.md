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
   ```

## data
### add raw mzml data and feature tables
- raw: "data/raw/" mzML files
- xcms: "data/xcms/" 
  - xcms output file "XCMS_full.csv"  
  - SERRF normalized file "normalized by - SERRF.csv"
- HMDB database: "data/hmdb_cleanup_v02062023.csv"

## Output

### XCMS feature clean up data
- Tables: "output/xcms_SERRF/
  - converted xcms file for SERRF normalization "SERRF_input.csv"
  - updata xcms features with SERRF noramlization "XCMS_full_normalized.csv"; "XCMS_full_normalized_noQC.csv"
### MS output data
- Tables: "output/"
  - MS matches with HMDB: "ms1mtch_hmdb_features.csv"
  - Features have msLevel 2 in spectra: "feature_hasMS2.csv"
- MS/MS matched results: "output/db/"
  - MS2 matches with database: "ms2mtch_FeatureName.csv"

## Reproducibility
- R version: See "session_info.txt"
- Dependencies: See "session_info.txt"; Scripts/00_setup.R
  