#################### Read mzml data fuction #################### 
read_mzml <- function(file_path){
  list_of_files <- list.files(path = file_path,
                              recursive = TRUE,
                              pattern = "\\.mzML$",
                              full.names = TRUE)
  sps <- Spectra(list_of_files)
  sps <- filterMsLevel(sps, msLevel = 2L)
  sps <- filterRt(sps, c(60,1200))
  return(sps)
}

##################### MS1 match #################### 
MS1_match <- function(df_features, df_db,db_param){
    MS1_match <- matchValues(df_features, 
                         df_db, 
                         db_param, mzColname= "mzmed")
    MS1_matched <- matchedData(MS1_match)[whichQuery(MS1_match),]
    MS1_matched <- MS1_matched[!is.na(MS1_matched$score),]
    MS1_matched <- MS1_matched[order(MS1_matched$ppm_error,decreasing = FALSE),]
    MS1_matched <- MS1_matched[!duplicated(MS1_matched$name),]
    MS1_matched$ID <- seq.int(nrow(MS1_matched))
    MS1_matched <- MS1_matched[,c("name","rtmed","mzmed","target_accession","target_exactmass","target_name","target_chemical_formula","ppm_error")]
    write.csv(MS1_matched, 
           here("output", paste0("ms1mtch_", substitute(df_db),"_",substitute(df_features), ".csv")))
           
    return(MS1_matched)

}


adduct <- "[M+H]+" # positive mode
db_param <- Mass2MzParam(adducts = adduct,
                     tolerance = 0.001, ppm = 5)
# xcms features
bacteria_features <- read.csv(here("data","xcms","XCMS_full_bacteria.csv"))
# hmdb database
hmdb <- read.csv(here("data","hmdb_cleanup_v02062023.csv"))
# ms1 level matche xcms features with hmdb
bacteria_ms1_matched <- MS1_match(bacteria_features,hmdb,db_param)

# read raw files and filter features with ms2
sps_all <- read_mzml(here("data","raw"))
sps_all_df <- spectraData(sps_all, c("msLevel","rtime","dataOrigin","precursorMz","scanIndex"))

df_features <- read.csv(here("output","ms1mtch_hmdb_bacteria_features.csv"))

features_param <- MzRtParam(ppm = 25, toleranceRt = 40)

matched_features <- matchMz(sps_all_df, 
                            df_features, param = features_param,
                            mzColname = c("precursorMz", "mzmed"),
                            rtColname = c("rtime","rtmed"))
features_match <- matchedData(matched_features)[whichQuery(matched_features),]
features_match <- features_match[!is.na(features_match$score),]
features_match <- features_match[order(features_match$ppm_error,decreasing = FALSE),]
features_match <-features_match[!duplicated(features_match$target_name),]
write.csv(features_match , here("output","feature_hasMS2.csv"))

features_match <- read.csv(here("output","feature_hasMS2.csv"))