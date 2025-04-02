##################### fuction for MS1 match #################### 
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
XCMS_features <- read.csv(here("data","xcms","XCMS_full.csv"))
# hmdb database
hmdb <- read.csv(here("data","hmdb_cleanup_v02062023.csv"))
# ms1 level matche xcms features with hmdb
XCMS_ms1_matched <- MS1_match(XCMS_features,hmdb,db_param)