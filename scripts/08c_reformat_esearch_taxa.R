# Reshape xtract taxonomy output into the wide format expected by
# 08_Transcript_Taxa_Identification.R
# Run after 08b_esearch_missing_taxids.sh
# Input:  TaxID_NA_esearch.txt  (TaxId + comma-separated rank_name pairs)
# Output: esearch_TaxIDs.txt    (tab-separated, no header; 8 columns:
#           TaxID, superkingdom, phylum, class, order, family, genus, species)

library(tidyr)

test <- read.delim("TaxID_NA_esearch.txt", sep = "\t", header = FALSE)

test <- test %>%
  separate_rows(V2, sep = ",") %>%
  separate(V2, c("level", "value"), sep = "_") %>%
  pivot_wider(names_from = level, values_from = value)

# Columns 1:7 = TaxId through genus; column 23 = species
test <- test[, c(1:7, 23)]
test <- apply(test, 2, as.character)

write.table(test, "esearch_TaxIDs.txt", quote = FALSE, sep = "\t",
            row.names = FALSE, col.names = FALSE)
