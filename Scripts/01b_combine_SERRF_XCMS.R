# read SERRF normalized data
df_normalized <- read.csv(here("data","xcms_SERRF","normalized by - SERRF.csv"))

df_normalized<- df_normalized %>%
  rowwise() %>%
  # find the sample has the most abundant ion count per feature
  mutate(max_sample = {
    # Select only numeric columns
    num_data <- select(., where(is.numeric))
    if (ncol(num_data) > 0) {
      names(num_data)[which.max(c_across(where(is.numeric)))]
    } else {
      NA_character_  
    }
  }) %>%
  ungroup()
# read original xcms output
df_xcms <- read.csv(here("data","xcms_SERRF","XCMS_full.csv"))

# update normalized ion counts by SERRF in xcms 
df_xcms_selected <- df_xcms%>% 
  select(name, mzmed, rtmed)

df_xcms_normalized <- df_xcms_selected %>% 
  inner_join(df_normalized , by = c("name" = "label")) %>%
  relocate(max_sample, .before = mzmed)

write.csv(df_xcms_normalized,here("output","xcms_SERRF","XCMS_full_normalized.csv"),row.names = FALSE)

# exclude QCs
df_xcms_normalized_noQC <- df_xcms_normalized %>% 
  select_if(!grepl("QC", names(.)))

write.csv(df_xcms_normalized_noQC,here("output","xcms_SERRF","XCMS_full_normalized_noQC.csv"),row.names = FALSE)
