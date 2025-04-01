df_normalized <- read.csv(here("data","xcms","normalized by - SERRF.csv"))

df_normalized<- df_normalized %>%
  rowwise() %>%
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

df_xcms <- read.csv(here("data","xcms","XCMS_full.csv"))

df_xcms_selected <- df_xcms%>% 
  select(name, mzmed, rtmed)

df_xcms_normalized <- df_xcms_selected %>% 
  inner_join(df_normalized , by = c("name" = "label")) %>%
  relocate(max_sample, .before = mzmed)

write.csv(df_xcms_normalized,here("data","xcms","XCMS_full_normalized.csv"),row.names = FALSE)

df_xcms_normalized_noQC <- df_xcms_normalized %>% 
  select_if(!grepl("QC", names(.)))

write.csv(df_xcms_normalized_noQC,here("data","xcms","XCMS_full_normalized_noQC.csv"),row.names = FALSE)
