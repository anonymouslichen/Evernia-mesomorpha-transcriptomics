# Install all R packages required by the Evernia transcriptome pipeline.
# Run once before executing any of the R scripts (steps 08, 10, 12).

# ── CRAN packages ─────────────────────────────────────────────────────────
cran_packages <- c(
  "dplyr",
  "tidyr",
  "tibble",
  "ggplot2",
  "statmod",
  "kableExtra",
  "stringr"
)

install.packages(cran_packages)

# ── Bioconductor packages ─────────────────────────────────────────────────
if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

bioc_packages <- c(
  "edgeR",
  "topGO",
  "GO.db",
  "ComplexHeatmap",
  "InteractiveComplexHeatmap"
)

BiocManager::install(bioc_packages)

# ── taxonomizr (CRAN, but needs a local taxonomy database) ───────────────
install.packages("taxonomizr")

# After installation, download the NCBI taxonomy database (done once;
# the resulting accessionTaxa.sql file is referenced in step 08):
#   taxonomizr::prepareTaxDB()
