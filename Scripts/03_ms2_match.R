#################### Read experimental mzml data fuction #################### 
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

#Fuction: Normalize intensities
norm_int <- function(x, ...) {
    maxint <- max(x[, "intensity"], na.rm = TRUE)
    x[, "intensity"] <- 100 * x[, "intensity"] / maxint
    x
}

#Fuction: Normalize MS/MS, 
low_int <- function(x, ...) {
    x > max(x, na.rm = TRUE) * (5 / 100 ) #remove the Int < 5%
}

# Fuction: Merge ms spectra
maxTic <- function(x, ...) {
  tic <- vapply(x, function(z) sum(z[, "intensity"], na.rm = TRUE),
                numeric(1))
  x[[which.max(tic)]]
}
# make a subfolder for ms2 match with library name
make_dir <- function(db) {
  # Get the name of the input object as character
  sub_dir <- deparse(substitute(db))
  
  # Create the full path using here::here()
  dir_path <- here::here("output", sub_dir)
  
  # Check if directory exists, if not create it
  if (!dir.exists(dir_path)) {
    dir.create(dir_path, recursive = TRUE)
    message("Created directory: ", dir_path)
  } else {
    message("Directory already exists: ", dir_path)
  }
  
  # Return the path invisibly
  invisible(dir_path)
}

# fuction for ms2 match
msms_match <- function(db,sps,df_match, polarity,parm_ms2) { 
    # noramlize db and sps
    db <- filterPolarity(db,polarity = polarity)
    db <- addProcessing(db,norm_int)
    print(db)
    sps_normalized <- addProcessing(sps, norm_int)
    sps_normalized <- filterIntensity(sps_normalized,intensity = low_int)
    print(sps_normalized)
    for (i in seq_len(nrow(df_match))){
        mz <- df_match$target_mzmed[i]
        id <- df_match$target_name[i]
        rt <- df_match$target_rtmed[i]
        sps_ms <- filterValues(sps_normalized,
        spectraVariables = c("precursorMz","rtime"),
        values = c(mz,rt), 
        tolerance = c(0.005, 20), 
        ppm = c(10,0), 
        match = "all")
        sps_agg <- combineSpectra(sps_ms, FUN = maxTic, minProp = 5)
          if (length(sps_agg)>2){
            mtch <- matchSpectra(sps_agg, db, parm_ms2)
            mtch_sub <- mtch[whichQuery(mtch)]
            df_mtch_sub <- apply(spectraData(mtch_sub),2,as.character)
            if(length(df_mtch_sub) == 0){
                message("No hit with mz = ", mz)
             }
            else{write.csv(df_mtch_sub,here("output", sub_dir, paste0("ms2mtch_", id, ".csv")))
            }
        }     
    }
}

# read raw files and filter features with ms2
sps_all <- read_mzml(here("data","raw"))
sps_all_df <- spectraData(sps_all, c("msLevel","rtime","dataOrigin","precursorMz","scanIndex"))

df_features <- read.csv(here("output","ms1mtch_hmdb_features.csv"))

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

###############################################
######### Parameter settings for MS2 ##########
###############################################
# threashold for MS2 matching scores
# mz search tolerance
parm_ms2 <- MatchForwardReverseParam(ppm = 20, requirePrecursor =FALSE,
                                     THRESHFUN = function(x) which(x >= 0.6)
                                     #THRESHFUN = select_top_match
)

features_match <- read.csv(here("output","feature_hasMS2.csv"))

library(AnnotationHub)
ah <- AnnotationHub()
query(ah, "MassBank")
mbank <- ah[["AH119519"]] |>
  Spectra()

# creat a subfolder
make_dic <- make_dir(mbank)
# match with mbank
msms_features_match <- msms_match(mbank, sps_all,features_match,polarity = 1 ,parm_ms2)


# creat a subfolder for inhouse lib
make_dic <- make_dir(mylib)
# match with mylib
msms_features_match <- msms_match(mylib, sps_all,features_match,polarity = 1 ,parm_ms2)

#sps_agg <- combineSpectra(sps_ms, peaks = "intersect", minProp = 1)
#print(sps_agg)

#sps_agg_max <- combineSpectra(sps_ms, FUN = maxTic)

