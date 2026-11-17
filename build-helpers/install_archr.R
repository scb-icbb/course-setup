# Installs ArchR (Project 2, scATAC) into the course environment.
#
# Run from the course-setup/ directory with the course env activated:
#
#   conda activate single-cell
#   Rscript build-helpers/install_archr.R
#
# Prerequisite: the conda packages listed under "ArchR dependencies" in
# environment-mac.yml / environment-linux.yml (chromVAR, motifmatchr,
# Rsamtools, BSgenome.Hsapiens.UCSC.hg38, harmony, nabor, ...). They are
# part of the env file, so a fresh `mamba env create` already has them.
# If the environment is already created, follow instructions on 
# README-ArchR.md on github course-setup apage.
#
# What this installs (GitHub-only packages, pinned):
#   - presto           immunogenomics/presto@v1.1.0   (fast Wilcoxon, used by getMarkerFeatures)
#   - chromVARmotifs   GreenleafLab/chromVARmotifs    (cisbp motif set for addMotifAnnotations)
#   - ArchR            GreenleafLab/ArchR v1.0.3 + one course patch (below)
#

options(repos = c(CRAN = "https://cloud.r-project.org"))
if (!requireNamespace("remotes", quietly = TRUE)) install.packages("remotes")

remotes::install_github("immunogenomics/presto@v1.1.0", upgrade = "never")
remotes::install_github("GreenleafLab/chromVARmotifs", upgrade = "never")

archr_version <- "1.0.3"
src_dir <- file.path(tempdir(), "archr-src")
dir.create(src_dir, showWarnings = FALSE)
tarball <- file.path(src_dir, "ArchR.tar.gz")
download.file(
  sprintf("https://github.com/GreenleafLab/ArchR/archive/refs/tags/v%s.tar.gz", archr_version),
  tarball, mode = "wb"
)
untar(tarball, exdir = src_dir)
pkg_dir <- file.path(src_dir, paste0("ArchR-", archr_version))

# --- course patch: make addGeneIntegrationMatrix work with SeuratObject 5 ---
f <- file.path(pkg_dir, "R", "RNAIntegration.R")
code <- readLines(f)
old_create <- grep('seuratATAC <- suppressWarnings(Seurat::CreateSeuratObject(counts = as.matrix(mat[head(seq_len(nrow(mat)), 5), , drop = FALSE])))', code, fixed = TRUE)
old_assay  <- grep('seuratATAC[["GeneScore"]] <- Seurat::CreateAssayObject(counts = mat)', code, fixed = TRUE)
old_default <- grep('DefaultAssay(seuratATAC) <- "GeneScore"', code, fixed = TRUE)
if (length(old_create) != 1 || length(old_assay) != 1 || length(old_default) != 1) {
  stop("ArchR source does not look like v", archr_version, " - patch not applied. Ask a tutor.")
}
code[old_create] <- paste0(
  "    # SCB course patch: use the reference's assay name so Seurat 4 + SeuratObject 5 can merge them\n",
  "    seuratATAC <- suppressWarnings(Seurat::CreateSeuratObject(counts = mat, assay = DefaultAssay(subRNA)))"
)
code[old_assay] <- ""
code[old_default] <- "    DefaultAssay(seuratATAC) <- DefaultAssay(subRNA)"
writeLines(code, f)

# dependencies = FALSE: everything ArchR imports is already in the env
# (from conda, or presto/chromVARmotifs above); this keeps remotes from
# upgrading pinned packages such as Seurat, Matrix or matrixStats.
remotes::install_local(pkg_dir, dependencies = FALSE, upgrade = "never", force = TRUE)

suppressPackageStartupMessages({
  library(Seurat)
  library(ArchR)
})
message("ArchR ", packageVersion("ArchR"), " installed (with Seurat ", packageVersion("Seurat"), ").")
