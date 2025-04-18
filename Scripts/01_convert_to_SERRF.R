# ---- 01. convert xcms output to serrf format  ----
XCMS_output<- read.csv(here("data","xcms_SERRF","XCMS_full.csv"), header = T, sep = ",", dec = ".", check.names = FALSE)

names(XCMS_output)[names(XCMS_output) == "name"] <- "label"

XCMS_output <- XCMS_output %>% 
  select_if(!grepl("QC0", names(.)))

XCMS_output_filter <- XCMS_output %>%
  select(-which(names(XCMS_output) != "label" & sapply(names(XCMS_output), function(col) length(strsplit(col, "_")[[1]]) <= 3)))
XCMS_output_filter  <- XCMS_output_filter  %>%
  filter(if_any(2:ncol(.), ~ . >= 20000))


qc_columns <- names(XCMS_output_filter)[grepl("QC", names(XCMS_output_filter))]
mean_qc <- rowMeans(XCMS_output_filter[, qc_columns], na.rm = TRUE)
std_qc <- apply(XCMS_output_filter[, qc_columns], 1, sd, na.rm = TRUE)
rsd <- std_qc / mean_qc
df_filtered <- XCMS_output_filter %>%
  mutate(RSD = rsd)
df_filtered <- df_filtered %>%
  filter(RSD <= 0.3)

#write.csv(df_filtered,here("output","xcms_SERRF","filtered_output_file.csv"),row.names = FALSE)

df_xcms <- df_filtered %>%
  select(-matches("RSD"))

# Order columns numerically based on suffix
data_cols <- setdiff(colnames(df_xcms), "label")
suffix_matches <- regmatches(data_cols, regexpr("_(\\d+)$", data_cols, perl = TRUE))
col_numbers <- as.numeric(gsub("_", "", suffix_matches))
col_numbers[is.na(col_numbers)] <- 0

# Create SERRF header rows
batch_row <- c("batch", rep("A", ncol(df_xcms) - 1))
sampleTypes <- ifelse(grepl("^QC", colnames(df_xcms)), "qc", "sample")
sampleTypes <- replace(sampleTypes, 1, "sampleType")
timeRow <- c("time", 1:(ncol(df_xcms) - 1))

# Bind rows to create SERRF input
df_SERRF <- rbind(batch_row, sampleTypes, timeRow, df_xcms)

# Write final SERRF input to CSV
write.csv(df_SERRF, here("output", "xcms_SERRF", "SERRF_input.csv"), row.names = FALSE)