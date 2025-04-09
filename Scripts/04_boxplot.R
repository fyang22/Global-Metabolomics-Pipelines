# ---- 04. plot significant features  ----
library(ggplot2)
library(here)
library(dplyr)
library(tidyverse)
# ---- with QC ----
# feature list
df_MetaboAnalyst_full <- read.csv(here("output","Metaboanalyst_input","MetaboAnalyst_withLabel.csv"))
df_MetaboAnalyst_full <- df_MetaboAnalyst_full[-1]
# feature name
df_feature <- read.csv((here("output","list_features_ms2.csv")))
#df_feature <- read.csv(here("data","Metaboanalyst","volcano.csv"))

df_plot <- df_MetaboAnalyst_full %>%
  filter(sample %in% df_feature$name) %>%                               
  t() %>%                                                      
  as.data.frame(stringsAsFactors = FALSE)%>%
  {colnames(.) <- as.character(unlist(.[1, ])); .[-1, ] }
df_plot$sample <- rownames(df_plot)
df_plot <- df_plot[, c("sample", setdiff(names(df_plot), "sample"))]
rownames(df_plot) <- NULL

df_plot$label <- ifelse(
  grepl("^QC", df_plot$sample, ignore.case = TRUE),
  "QC",
  sub("^([A-Za-z]+\\.[A-Za-z0-9]+).*", "\\1", df_plot$sample)
)

write.csv(df_plot,here("output","Metaboanalyst_input","boxplot.csv"))

# Pivot to long format
df_long <- df_plot %>%
  pivot_longer(
    cols = -c(sample, label),
    names_to = "feature",
    values_to = "intensity"
    
  ) %>%
  replace_na(list(intensity = 0))%>%
  mutate(intensity = as.numeric(intensity))

# Create a folder to save plots
plot_dir <- here("output","plots")
if (!dir.exists(plot_dir)) dir.create(plot_dir, recursive = TRUE)

# Loop through each feature and save the plot
unique_features <- unique(df_long$feature)

for (f in unique_features) {
  p <- df_long %>%
    filter(feature == f) %>%
    ggplot(aes(x = label, y = intensity, color = label)) +
    geom_boxplot(outlier.shape = NA, alpha = 0.4) +
    geom_jitter(width = 0.2, alpha = 0.7) +
    scale_y_continuous(breaks = scales::pretty_breaks(n = 5)) +
    theme_minimal() +
    labs(
      title = paste(f),
      x = "Sample Type",
      y = "Intensity"
    ) +
    theme(
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      axis.text.x = element_text(angle = 45, hjust = 1),
      legend.position = "none"
    )

  ggsave(
    filename = paste0(plot_dir, "/", f, ".png"),
    plot = p,
    width = 6,
    height = 4,
    dpi = 300
  )
}

#write.csv(df_plot,here("output","Metaboanalyst_input","boxplot.csv"))

#df_MetaboAnalyst_full_noQC <- read.csv(here("output","Metaboanalyst_input","MetaboAnalyst_withLabel_noQC.csv"))

