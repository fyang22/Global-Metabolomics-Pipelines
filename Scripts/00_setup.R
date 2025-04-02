###############################################
### Load or install packages ##################
###############################################

# Read session_info.txt (if saved)
session_text <- readLines("session_info.txt")

# Extract package names (regex for "package_name_version")
pkgs <- gsub(".*([a-zA-Z0-9]+)_[0-9.]+.*", "\\1", session_text)
pkgs <- unique(pkgs[!grepl("R|locale|attached base", pkgs)])

if (!require("here")) install.packages("here")
library(here)

if (!require("dplyr")) install.packages("dplyr")
library(dplyr)

if (!require("tidyr")) install.packages("tidyr")
library(tidyr)

if (!require("pander")) install.packages("pander")
library(pander)

if (!require("devtools")) install.packages("devtools")

if (!require("Spectra")) devtools::install_github("rformassspectrometry/Spectra")
library(Spectra)

if (!require("MetaboAnnotation")) devtools::install_github("rformassspectrometry/MetaboAnnotation")
library(MetaboAnnotation)

if (!require("MsBackendMassbank")) devtools::install_github("rformassspectrometry/MsBackendMassbank")
library(MsBackendMassbank)

if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
if (!require("mzR")) BiocManager::install("mzR")

if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
if (!require("CompoundDb")) BiocManager::install("CompoundDb")
library(CompoundDb)

if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
if (!require("MsBackendMgf")) BiocManager::install("MsBackendMgf")
library(MsBackendMgf)

if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
if (!require("AnnotationHub")) BiocManager::install("AnnotationHub")
library(AnnotationHub)
ah <- AnnotationHub()

if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
if (!require("Spectra")) BiocManager::install("Spectra")
library(Spectra)

if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
if (!require("BiocParallel")) BiocManager::install(("BiocParallel"),force = TRUE)
library(BiocParallel)



# Set working directory to repo root
setwd(here())
# Verify
print(paste("Working directory set to:", getwd()))
if (!dir.exists(here("output"))) {
  dir.create(here("output"))
}
# Save session info
writeLines(capture.output(sessionInfo()), "session_info.txt")