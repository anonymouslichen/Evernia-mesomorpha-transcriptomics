#Script for choosing gene identification for the longest splicing isoform for each gene. 
#Author:Abigail Meyer
#Last Edit: 12/07/2023

library(tidyr)
library(dplyr)
library(stringr)

#Read in Gene Ids (output from blastp search against uniprot database)
gene_ids <- read.csv("longest_isoform_gene_identification.csv", header = FALSE, sep = ",", quote = "", row.names = NULL, stringsAsFactors = FALSE)
gene_ids <- gene_ids[,c(2,5,6,7)]
colnames(gene_ids) <- c("iso", "Evalue", "Gene", "Organism")

#Read in Lichen-forming fungus isoforms (generated in Differential_Expression&GO_analysis.R)
myco_ids <- read.csv("Fungal_isoforms.csv", header = FALSE)
colnames(myco_ids) <- "iso"
myco_gene_ids <- left_join(myco_ids, gene_ids, keep = FALSE)

#Read in Lihcen-forming algal isoforms (generated in Differential_Expression&GO_analysis.R)
photo_ids <- read.csv("Algal_isoforms.csv", header = FALSE)
colnames(photo_ids) <- "iso"
photo_gene_ids <- left_join(photo_ids, gene_ids, keep = FALSE)

#Read in Lichen-assoicated basidiomycete isoforms (generated in Differential_Expression&GO_analysis.R)
basidio_ids <- read.csv("Basidio_isoforms.csv", header = FALSE)
colnames(basidio_ids) <- "iso"
basidio_gene_ids <- left_join(basidio_ids, gene_ids, keep = FALSE)

#Read in lichen-associated bacteria isoforms (generated in Differential_Expression&GO_analysis.R)
bac_ids <- read.csv("Bacteria_isoforms.csv", header = FALSE)
colnames(bac_ids) <- "iso"
bac_gene_ids <- left_join(bac_ids, gene_ids, keep = FALSE)

#Read in file that contains taxonomic data for each uniprot gene_organism.
accession <- read.csv("uniprot_accession.csv", header = TRUE, row.names = NULL)
colnames(accession) <- c("Gene", "Organism", "LinkID", "TaxonomyValue")
accession <- accession[,-1]
accession <- accession %>%
  distinct()
#Filter fungal genes
accession_fungi <- accession %>%
  filter(str_detect(TaxonomyValue, "Fungi"))
accession_algae <- accession %>%
#Filter plant genes
  filter(str_detect(TaxonomyValue, "Viridiplantae"))
#Filter bacteria genes
accession_bac <- accession %>%
  filter(str_detect(TaxonomyValue, "Bacteria"))

#Only keep fungal gene blastp results for lichen-forming fungi isoforms
gene_ids_myco_keeps <- inner_join(myco_gene_ids, accession_fungi, by = "Organism")
#Only keep plant gene blastp results for lichen-forming algae isoforms
gene_ids_photo_keeps <- inner_join(photo_gene_ids, accession_algae, by = "Organism")
#Only keep fungal gene blastp results for lichen-associated basidiomycete isoforms
gene_ids_basidio_keeps <- inner_join(basidio_gene_ids, accession_fungi, by = "Organism")
#Only keep bacterial gene blastp results for lichen-associated bacteria isoforms
gene_ids_bac_keeps <- inner_join(bac_gene_ids, accession_bac, by = "Organism")

#Add "biont" (associated organism) column
gene_ids_myco_keeps$Biont <- "Mycobiont"
gene_ids_photo_keeps$Biont <- "Photobiont"
gene_ids_basidio_keeps$Biont <- "Basidiobiont"
gene_ids_bac_keeps$Biont <- "Bacteriabiont"

#Combine all isoforms
gene_ids_keeps <- rbind(gene_ids_myco_keeps, gene_ids_photo_keeps, gene_ids_basidio_keeps, gene_ids_bac_keeps)

#Filter best blastp hit for each isoform
best_evalue_gene_ids <- gene_ids_keeps  %>% 
  group_by(iso) %>%
  filter(Evalue == min(Evalue)) %>%
  distinct(iso, .keep_all = TRUE)  

write.csv(best_evalue_gene_ids, "best_evalue_gene_ids.csv")