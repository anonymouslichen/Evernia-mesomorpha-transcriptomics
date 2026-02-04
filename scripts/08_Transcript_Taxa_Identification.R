#Script for identifying longest splicing isoform for each ORF produced from Trinity de novo transcriptome assembly and assign taxonomy i.e. organism from which each transcipt can be derived. 
#Last Edit: 12/07/2023

library(tidyr)
library(dplyr)

#read in file containing open reading frames (ORF) identifiers from the Trinity transdecoder output. Identifiers have been edited to separate all fields. 
orf_id <- read.delim("transdecoder_ORF_IDs.txt", header = FALSE, sep = "\t")
colnames(orf_id) <- c("gene", "iso", "g", "len")

#Make data frame of longest splicing isoform per gene. Some have the same length, (2750), I will choose to keep at this point and remove when filtering the best evalue for each ORF.
orf_id_keeps <- orf_id %>% 
  group_by(gene) %>%
  filter(len == max(len))

#Read in blast table, which contains blastp search results for the longest splicing isoform (reduced set to speed blast search).
blastp <- read.delim("longest_isoform_blastp.txt", header = FALSE, sep = "\t")
colnames(blastp) <- c("gene","iso", "g", "m", "evalue", "TaxID")

#use orf_id_keep to filter which ORFs correspond to the longest splicing isoform for each gene/gene
blast_keeps <- left_join(orf_id_keeps, blastp, by = "g")
blast_keeps <- blast_keeps[,c(1,2,8,9)]
colnames(blast_keeps) <- c("gene","iso", "evalue", "TaxID")

#For each gene, only keep the ORF with an evalue = O or the minimum evalue. For those which have more than one evalue = 0, keep the first record
best_evalue <-  blast_keeps  %>% 
  group_by(gene) %>%
  slice_min(evalue, with_ties = FALSE) 

#Build taxonomy file based on TaxIDs
library(taxonomizr)
ids <- best_evalue$TaxID
blastp_taxonomy  <- getTaxonomy(ids,'accessionTaxa.sql')
write.csv(blastp_taxonomy, file = "blastp_taxonomy.csv")

#Read in taxonomizr output containing taxonomic information for TaxIDs retrieved in blastp search 
taxonomy <- read.csv("blastp_taxonomy.csv", header = TRUE)
colnames(taxonomy) <- c("TaxID", "superkingdom", "phylum", "class", "order", "family", "genus","species")
taxonomy <- taxonomy[!duplicated(taxonomy),]
#Pull TaxIDs for which taxonomizr did not
NAs <- taxonomy[(is.na(taxonomy)) == 7, 1]
#Write file and perform esearch using Enterez Direct 
write.table(NAs, "TaxID_NA.txt", quote = FALSE, sep = "\t", row.names = FALSE, col.names = FALSE) 

#Read in esearch taxonomic file 
tax_esearch <- read.delim("esearch_TaxIDs.txt", header = FALSE, sep = "\t")
colnames(tax_esearch) <- c("TaxID", "superkingdom", "phylum", "class", "order", "family", "genus","species")
taxonomy <- rbind(taxonomy,tax_esearch)
taxonomy$TaxID <- as.double(taxonomy$TaxID)
#Join to merge TaxIDs with taxnomic information
gene_ids <- left_join(best_evalue, taxonomy, by = "TaxID")

#Read in gene count matrix
gene_count_matrix <- read.delim("Trinity.gene.counts.matrix", header = FALSE, sep = "\t")
colnames(gene_count_matrix) <- c("gene", "dry_1", "dry_2", "dry_3", "dry_4", "dry_5", "liquid_1", "liquid_2", "liquid_3", "liquid_4", "liquid_5", "vapor_1", "vapor_2", "vapor_3", "vapor_4", "vapor_5")
gene_count_matrix <- gene_count_matrix[-1,]
gene_count_matrix_ids <- left_join(gene_count_matrix, gene_ids, by = "gene") %>%
  distinct(gene, .keep_all = TRUE)
gene_count_matrix_ids <- gene_count_matrix_ids[,-c(18)]

write.csv(gene_count_matrix_ids, file = "gene_count_matrix_taxa.csv", row.names = FALSE)