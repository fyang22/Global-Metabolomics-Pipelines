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

msms_match <- function(db,sps,df_match, polarity,parm_ms2) {

    sub_dir <- paste0((substitute(db)))

# check if sub directory exists 
    if (!dir.exists(here("output",sub_dir))){    
    } 
    else {		
		dir.create(here("output", sub_dir))		
    }  
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
###############################################
######### Parameter settings for MS2 ##########
###############################################
# threashold for MS2 matching scores
# mz search tolerance
parm_ms2 <- MatchForwardReverseParam(ppm = 20, requirePrecursor =FALSE,
                                     THRESHFUN = function(x) which(x >= 0.6)
                                     #THRESHFUN = select_top_match
)

library(AnnotationHub)
ah <- AnnotationHub()
query(ah, "MassBank")
mbank <- ah[["AH119519"]] |>
  Spectra()


msms_features_match <- msms_match(mbank, sps_all,features_match,polarity = 1 ,parm_ms2)

#sps_agg <- combineSpectra(sps_ms, peaks = "intersect", minProp = 1)
#print(sps_agg)

#sps_agg_max <- combineSpectra(sps_ms, FUN = maxTic)
