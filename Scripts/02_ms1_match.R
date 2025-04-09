# ---- 02. m/z match with HMDB ----
MS1_match <- function(df_features, df_db,db_param){
    MS1_match <- matchValues(df_features, 
                         df_db, 
                         db_param, mzColname= "mzmed")
    MS1_matched <- matchedData(MS1_match)#[whichQuery(MS1_match),]
    MS1_matched <- MS1_matched[!is.na(MS1_matched$ppm_error),]
    MS1_matched <- MS1_matched[order(MS1_matched$ppm_error,decreasing = FALSE),]
    MS1_matched <- MS1_matched[!duplicated(MS1_matched$name),]
    MS1_matched$ID <- seq.int(nrow(MS1_matched))
    MS1_matched <- MS1_matched[,c("name","rtmed","mzmed","target_accession","target_exactmass","target_name","target_chemical_formula","ppm_error")]
    write.csv(MS1_matched, 
           here("output", paste0("ms1mtch_", substitute(df_db),"_",substitute(df_features), ".csv")))
           
    return(MS1_matched)

}

adduct <- "[M-H]-" # positive mode
db_param <- Mass2MzParam(adducts = adduct,
                     tolerance = 0.001, ppm = 5)
# normalized xcms features
XCMS <- read.csv(here("output","xcms_SERRF","XCMS_full_normalized.csv"))
#names(XCMS)[names(XCMS) == "name"] <- "sample"

# hmdb database
hmdb <- read.csv(here("data","hmdb_cleanup_v02062023.csv"))
# ms1 level matche xcms features with hmdb
XCMS_ms1_matched <- MS1_match(XCMS,hmdb,db_param)   

# ---- generate metaboanalyst table  ----
# Subset ms1 match features with XCMS for MetaboAnalyst
df_MetaboAnalyst <- XCMS %>% 
  filter(name %in% XCMS_ms1_matched$name) %>%
  select(-any_of(c("max_sample", "mzmed", "rtmed")))
 
# ---- without label  ----
# save features for metaboanalyst with qcs
write.csv(df_MetaboAnalyst, here("output","Metaboanalyst_input","MetaboAnalyst_features.csv"))

# save features for metaboanalyst without qcs
df_MetaboAnalyst_noQC <- df_MetaboAnalyst %>% 
  select(-matches("QC", ignore.case = TRUE))
write.csv(df_MetaboAnalyst_noQC, here("output","Metaboanalyst_input","MetaboAnalyst_features_noQC.csv"))

# ---- with label  ----
# samples names : QC0-9, group.subgroup.sampleid_0-9_
groups <- setdiff(colnames(df_MetaboAnalyst), "sample")
sample_groups <- ifelse(
  grepl("^QC", groups),
  "QC",
  sub("^([A-Za-z]+\\.[A-Za-z0-9]+).*", "\\1", groups)
)
sample_row <- data.frame(t(c("label", sample_groups)), stringsAsFactors = FALSE)
colnames(sample_row) <- colnames(df_MetaboAnalyst)
df_MetaboAnalyst_full <- rbind(sample_row, df_MetaboAnalyst)
write.csv(df_MetaboAnalyst_full, here("output","Metaboanalyst_input","MetaboAnalyst_withLabel.csv"))

df_MetaboAnalyst_full_noQC <- df_MetaboAnalyst_full %>% 
  select(-matches("QC", ignore.case = TRUE))
write.csv(df_MetaboAnalyst_full_noQC, here("output","Metaboanalyst_input","MetaboAnalyst_withLabel_noQC.csv"))
