#R Script for testing Differential Expression between vapor water and liquid water hydrated Evernia mesomorpha lichen thalli, produce Figure 2 perform GO term enrichment analysis and produce supplementary tables XXX and figures XXX
#Last edit: 2/15/2023
#Author: Abigail Meyer

library(dplyr)
library(edgeR)
library(tibble)
library(ggplot2)
library(tidyr)
library(statmod)

#read in matrix of genes and expression awith taxa information (output of )
matrix <- read.csv("gene_count_matrix_taxa.csv")

#Drop genes with unknown taxa ID
matrix_narm <- matrix %>%
  drop_na(TaxID)
matrix_filter <- matrix_narm %>%
  column_to_rownames(var="iso")

#Remove "noise" by filtering any gene that wasn't expressed across all dry, vapor or liquid samples
matrix_filter <- matrix_filter[,-c(1,17:26)]
#Convert expression values to 0 or 1 if not 0
matrix_filter[matrix_filter != 0] <- 1
#Sum across conditions 
matrix_filter <- matrix_filter %>%
  mutate(sum_Dry = rowSums(.[1:5])) %>%
  mutate(sum_Vapor = rowSums(.[6:10])) %>%
  mutate(sum_Liquid = rowSums(.[11:15])) 
matrix_filter <- matrix_filter[,-(1:15)]
#Remove any gene that doesn't contain a 5 (i.e. wasn't expressed in all dry, vapor or liquid samples)
matrix_filter <- matrix_filter %>%
  filter_all(any_vars(. %in% 5))

#Use the filtered matrix to filter the original matrix with raw expression values
matrix_narm <- matrix_narm %>%
  column_to_rownames(var="iso")
matrix_keeps <- matrix_narm[rownames(matrix_filter),]

# #Run to produce input files for identifying gene function: Gene_Function_Identification.R
# algae <- matrix_narm %>%
#   filter(phylum == "Chlorophyta")
# algae <- as.data.frame(algae$gene)
# write.csv(algae, file = "Algal_isoforms.csv", quote = FALSE, row.names = FALSE)
# 
# asco <- matrix_narm %>%
#   filter(phylum == "Ascomycota")
# asco <- as.data.frame(asco$gene)
# write.csv(asco, file = "Fungal_isoforms.csv", quote = FALSE, row.names = FALSE)
# 
# basidio <- matrix_narm %>%
#   filter(phylum == "Basidiomycota")
# basidio <- as.data.frame(basidio$gene)
# write.csv(basidio, file = "Basidio_isoforms.csv", quote = FALSE, row.names = FALSE)
# 
# bac <- matrix_narm %>%
#   filter(superkingdom == "Bacteria")
# bac <- as.data.frame(bac$gene)
# write.csv(bac, file = "Bacteria_isoforms.csv", quote = FALSE, row.names = FALSE)


#Filter matrices by symbiont for EdgeR model construction 
#Lichen-forming alga
A <- matrix_keeps %>%  
  filter(class == "Trebouxiophyceae")
A <- A[,-c(1,17:26)]
#Lichen-forming fungus
G <- matrix_keeps %>%
  filter(class == "Lecanoromycetes")
G <- G[,-c(1,17:26)]
#Lichen-associated bacteria
B <- matrix_keeps %>%
  filter(superkingdom == "Bacteria")
B <- B[,-c(1,17:26)]
#Lichen-associated basidiomycetes
B2 <- matrix_keeps %>%
  filter(phylum == "Basidiomycota")
B2 <- B2[,-c(1,17:26)]

#Read in file of lichen-forming fungus assigned genes BLAST searched against the Evernia prunastri genome. 
blast <- read.delim("E.meso_E.prun_blast.out", sep = "\t", header = FALSE)
colnames(blast) <- c("qseqid", "sseqid","pident", "length", "mismatch", "gapopen", "qstart", "qend", "sstart", "send", "evalue", "bitscore")
#Filter lichen-forming fungus isoforms
e_mes_isos <- as.data.frame(rownames(G))
colnames(e_mes_isos) <- "qseqid"
e_mes <- left_join(e_mes_isos, blast)
#keep only the result with the highest percent identity match across each isoform
best_blast <-  e_mes  %>% 
  group_by(qseqid) %>%
  slice_max(pident, with_ties = FALSE) 
#Remove NAs (i.e. those which did not match the E. prunastri genome) for the lichen-forming fungus matrix
blast_na <- as.vector(unlist(best_blast[is.na(best_blast$pident),1]))
G <- G[!rownames(G) %in% blast_na,]

#Great grouping variable of replicates for EdgeR object 
group <- c("Dry", "Dry", "Dry", "Dry", "Dry", "Liquid", "Liquid", "Liquid", "Liquid", "Liquid", "Vapor", "Vapor", "Vapor", "Vapor", "Vapor")

#Create edgeR objects
#Algae
Alg <- DGEList(counts = as.matrix(A), group = group)
#Fungi
Fun <- DGEList(counts = as.matrix(G), group = group)
#Bacteria
Bac <- DGEList(counts = as.matrix(B), group = group)
#Basidios
Bas <- DGEList(counts = as.matrix(B2), group = group)

#Remove genes that were expresseed < 100x across all samples
#Algae
keep_a <- rowSums(cpm(Alg)>100) >= 1
Alg <- Alg[keep_a, , keep.lib.sizes = FALSE]
#Fungi
keep_f <- rowSums(cpm(Fun)>100) >= 1
Fun <- Fun[keep_f, , keep.lib.sizes = FALSE]
#Bacteria
keep_b <- rowSums(cpm(Bac)>100) >= 1
Bac <- Bac[keep_b, , keep.lib.sizes = FALSE]
#Basidios
keep_b2 <- rowSums(cpm(Bas)>100) >= 1
Bas <- Bas[keep_b2, , keep.lib.sizes = FALSE]

#Calculate normalization factors. Scaling uses a trimmed mean of M-values (TMM) betweeen each pair of samples
Alg <- calcNormFactors(Alg)
Fun <- calcNormFactors(Fun)
Bac <- calcNormFactors(Bac)
Bas <- calcNormFactors(Bas)

#Calculate log CPMs
logcpms_Alg <- as.data.frame(cpm(Alg, normalized.lib.sizes = TRUE, log=TRUE))
logcpms_Fun <- as.data.frame(cpm(Fun, normalized.lib.sizes = TRUE, log=TRUE))
logcpms_Bac <- as.data.frame(cpm(Bac, normalized.lib.sizes = TRUE, log=TRUE))
logcpms_Bas <- as.data.frame(cpm(Bas, normalized.lib.sizes = TRUE, log=TRUE))

#Explore normalized data
boxplot(logcpms_Alg, col = "gray", las = 2, ylab = "Log CPM")
boxplot(logcpms_Fun, col = "gray")
boxplot(logcpms_Bac, col = "gray")
boxplot(logcpms_Bas, col = "gray")
plotMDS(logcpms_Alg)
plotMDS(logcpms_Fun)
plotMDS(logcpms_Bac)
plotMDS(logcpms_Bas)
plot(density(rowSums(logcpms_Alg)))
plot(density(rowSums(logcpms_Fun)))
plot(density(rowSums(logcpms_Bac)))
plot(density(rowSums(logcpms_Bas)))

#Create design matrix for model construction 
design <- model.matrix(~0 + group, data = Alg) #Same for Alg, Fun and Bas

#Estimate dispersions, which represents the variance in gene expression for a given mean value
Alg <- estimateDisp(Alg, design)
Fun <- estimateDisp(Fun, design)
Bac <- estimateDisp(Bac, design)
Bas <- estimateDisp(Bas, design)
plotBCV(Alg, main="BCV Plot")
plotBCV(Fun, main="BCV Plot")
plotBCV(Bac, main="BCV Plot")
plotBCV(Bas, main="BCV Plot")

#Fit a negative binomial GLM to each taxanomoic group
fit_alg <- glmQLFit(Alg, design, robust = TRUE)
fit_fun <- glmQLFit(Fun, design, robust = TRUE)
fit_bac <- glmQLFit(Bac, design, robust = TRUE)
fit_bas <- glmQLFit(Bas, design, robust = TRUE)
plotQLDisp(fit_alg)
plotQLDisp(fit_fun)
plotQLDisp(fit_bac)
plotQLDisp(fit_bas)

#Use quasiliklihood F-test to test significant differences between each conditions
#Compare liquid to vapor
fun_V_L <- glmQLFTest(fit_fun, contrast=c(0,1,-1))
alg_V_L <- glmQLFTest(fit_alg, contrast=c(0,1,-1))
bac_V_L <- glmQLFTest(fit_bac, contrast=c(0,1,-1))
bas_V_L <- glmQLFTest(fit_bas, contrast=c(0,1,-1))
#Compare liquid to dry
fun_D_L <- glmQLFTest(fit_fun, contrast=c(-1,1,0))
alg_D_L <- glmQLFTest(fit_alg, contrast=c(-1,1,0))
bac_D_L <- glmQLFTest(fit_bac, contrast=c(-1,1,0))
bas_D_L <- glmQLFTest(fit_bas, contrast=c(-1,1,0))
#Compare vapor to dry
fun_D_V <- glmQLFTest(fit_fun, contrast=c(-1,0,1))
alg_D_V <- glmQLFTest(fit_alg, contrast=c(-1,0,1))
bac_D_V <- glmQLFTest(fit_bac, contrast=c(-1,0,1))
bas_D_V <- glmQLFTest(fit_bas, contrast=c(-1,0,1))

#Decide which genes are DEGs
#Algae
summary(de_alg_D_L <- decideTestsDGE(alg_D_L, p=0.05, lfc=1, adjust="BH"))
summary(de_alg_D_V <- decideTestsDGE(alg_D_V, p=0.05, lfc=1, adjust="BH"))
summary(de_alg_V_L <- decideTestsDGE(alg_V_L, p=0.05, lfc=1, adjust="BH"))
#Lecanoromycte
summary(de_fun_D_L <- decideTestsDGE(fun_D_L, p=0.05, lfc=1, adjust="BH"))
summary(de_fun_D_V <- decideTestsDGE(fun_D_V, p=0.05, lfc=1, adjust="BH"))
summary(de_fun_V_L <- decideTestsDGE(fun_V_L, p=0.05, lfc=1, adjust="BH"))
#Bacteria
summary(de_bac_D_L <- decideTestsDGE(bac_D_L, p=0.05, lfc=1, adjust="BH"))
summary(de_bac_D_V <- decideTestsDGE(bac_D_V, p=0.05, lfc=1, adjust="BH"))
summary(de_bac_V_L <- decideTestsDGE(bac_V_L, p=0.05, lfc=1, adjust="BH"))
#Basidios
summary(de_bas_D_L <- decideTestsDGE(bas_D_L, p=0.05, lfc=1, adjust="BH"))
summary(de_bas_D_V <- decideTestsDGE(bas_D_V, p=0.05, lfc=1, adjust="BH"))
summary(de_bas_V_L <- decideTestsDGE(bas_V_L, p=0.05, lfc=1, adjust="BH"))


#Extract DE statistics for algae
stat_alg_V_L <- topTags(alg_V_L, n = "Inf")$table
stat_alg_V_L$Comparison <- "Vapor_Liquid"
stat_alg_V_L <- rownames_to_column(stat_alg_V_L, var = "iso")
stat_alg_D_L <- topTags(alg_D_L, n = "Inf")$table
stat_alg_D_L$Comparison <- "Dry_Liquid"
stat_alg_D_L <- rownames_to_column(stat_alg_D_L, var = "iso")
stat_alg_D_V <- topTags(alg_D_V, n = "Inf")$table
stat_alg_D_V$Comparison <- "Dry_Vapor"
stat_alg_D_V <- rownames_to_column(stat_alg_D_V, var = "iso")
#combine each comparison
stat_alg <- rbind(stat_alg_V_L, stat_alg_D_L, stat_alg_D_V)
stat_alg <- stat_alg[,-c(3,4)]
stat_alg$Biont <- "Photobiont"

#Extract DE statistics for fungi
stat_fun_V_L <- topTags(fun_V_L, n = "Inf")$table
stat_fun_V_L$Comparison <- "Vapor_Liquid"
stat_fun_V_L <- rownames_to_column(stat_fun_V_L, var = "iso")
stat_fun_D_L <- topTags(fun_D_L, n = "Inf")$table
stat_fun_D_L$Comparison <- "Dry_Liquid"
stat_fun_D_L <- rownames_to_column(stat_fun_D_L, var = "iso")
stat_fun_D_V <- topTags(fun_D_V, n = "Inf")$table
stat_fun_D_V$Comparison <- "Dry_Vapor"
stat_fun_D_V <- rownames_to_column(stat_fun_D_V, var = "iso")
#combine each comparison
stat_fun <- rbind(stat_fun_V_L, stat_fun_D_L, stat_fun_D_V)
stat_fun <- stat_fun[,-c(3,4)]
stat_fun$Biont <- "Mycobiont"

#Extract DE statistics for bacteria
stat_bac_V_L <- topTags(bac_V_L, n = "Inf")$table
stat_bac_V_L$Comparison <- "Vapor_Liquid"
stat_bac_V_L <- rownames_to_column(stat_bac_V_L, var = "iso")
stat_bac_D_L <- topTags(bac_D_L, n = "Inf")$table
stat_bac_D_L$Comparison <- "Dry_Liquid"
stat_bac_D_L <- rownames_to_column(stat_bac_D_L, var = "iso")
stat_bac_D_V <- topTags(bac_D_V, n = "Inf")$table
stat_bac_D_V$Comparison <- "Dry_Vapor"
stat_bac_D_V <- rownames_to_column(stat_bac_D_V, var = "iso")
#combine each comparison
stat_bac <- rbind(stat_bac_V_L, stat_bac_D_L, stat_bac_D_V)
stat_bac <- stat_bac[,-c(3,4)]
stat_bac$Biont <- "Bacteriabiont"

#Extract DE statistics for basidios
stat_bas_V_L <- topTags(bas_V_L, n = "Inf")$table
stat_bas_V_L$Comparison <- "Vapor_Liquid"
stat_bas_V_L <- rownames_to_column(stat_bas_V_L, var = "iso")
stat_bas_D_L <- topTags(bas_D_L, n = "Inf")$table
stat_bas_D_L$Comparison <- "Dry_Liquid"
stat_bas_D_L <- rownames_to_column(stat_bas_D_L, var = "iso")
stat_bas_D_V <- topTags(bas_D_V, n = "Inf")$table
stat_bas_D_V$Comparison <- "Dry_Vapor"
stat_bas_D_V <- rownames_to_column(stat_bas_D_V, var = "iso")
#combine each comparison
stat_bas <- rbind(stat_bas_V_L, stat_bas_D_L, stat_bas_D_V)
stat_bas <- stat_bas[,-c(3,4)]
stat_bas$Biont <- "Basidiobiont"


#Combine 
stats <- rbind(stat_fun, stat_alg, stat_bac, stat_bas)

#Upload gene ID table, output from Gene_Function_Identification.R
gene_ids <- read.csv("best_evalue_gene_ids.csv")
gene_ids <- gene_ids %>%
  unite("Uniprot_ID", Gene:Organism, sep = "_", remove = TRUE)
gene_ids <- gene_ids[,c(2,4,7)]
#write.csv(gene_ids, "uniprot_search.csv")

#Make topGO custom annotations for each biont, used later in topGO Analysis.
uniprot2go <- read.csv("uniprot2go.csv")
topGO_map <- left_join(gene_ids, uniprot2go)
topGO_map$GO <- gsub(";", ",", topGO_map$GO)
topGO_algae <- topGO_map[(topGO_map$Biont == "Photobiont"),c(1,4)]
topGO_fungi <- topGO_map[(topGO_map$Biont == "Mycobiont"),c(1,4)]
topGO_bacteria <- topGO_map[(topGO_map$Biont == "Bacteriabiont"),c(1,4)]
topGO_basidio <- topGO_map[(topGO_map$Biont == "Basidiobiont"),c(1,4)]
write.table(topGO_algae, "topGO_algae.txt", quote = FALSE, sep = "\t", row.names = FALSE, col.names = FALSE)
write.table(topGO_fungi, "topGO_fungi.txt", quote = FALSE, sep = "\t", row.names = FALSE, col.names = FALSE)
write.table(topGO_bacteria, "topGO_bacteria.txt", quote = FALSE, sep = "\t", row.names = FALSE, col.names = FALSE)
write.table(topGO_basidio, "topGO_basidios.txt", quote = FALSE, sep = "\t", row.names = FALSE, col.names = FALSE)

#Extract average logCPMs 
logcpms_Alg$Av.logCPM <- aveLogCPM(Alg)
logcpms_Alg <- rownames_to_column(logcpms_Alg, var = "iso")
logcpms_Fun$Av.logCPM <- aveLogCPM(Fun)
logcpms_Fun <- rownames_to_column(logcpms_Fun, var = "iso")
logcpms_Bac$Av.logCPM <- aveLogCPM(Bac)
logcpms_Bac <- rownames_to_column(logcpms_Bac, var = "iso")
logcpms_Bas$Av.logCPM <- aveLogCPM(Bas)
logcpms_Bas <- rownames_to_column(logcpms_Bas, var = "iso")
#Combine
cpms <- rbind(logcpms_Alg, logcpms_Fun, logcpms_Bac, logcpms_Bas)


#Create dataframe for volcano plots, including differential expression statistics, transcript taxa, and log CPMs.
model_results <- left_join(stats, gene_ids, keep = FALSE, multiple = "all")
model_results <- left_join(model_results, cpms)
model_results$diffexpressed <- "NS"
model_results$diffexpressed[model_results$logFC >= 1 & model_results$FDR <= 0.05] <- "UP"
model_results$diffexpressed[model_results$logFC <= -1 & model_results$FDR <= 0.05] <- "DOWN"
model_results <- model_results %>%
  mutate(diffexpressed = as.factor(diffexpressed))
model_results <- model_results %>%
  arrange(factor(diffexpressed, levels = c("NS", "UP", "DOWN")))

#Fig. 2B Differential expression between water vapor and liquid water hydrated lecanoromycete transcriptome. 
myco_VL <- ggplot(subset(model_results, Comparison == "Vapor_Liquid" & Biont == "Mycobiont"), aes(x = Av.logCPM, y = logFC, col = diffexpressed)) +
  geom_point(aes(size = diffexpressed)) +
  scale_color_manual(values = c("blue", "black", "red")) +
  scale_size_manual(values=c(2.5,1.5,2.5)) +
  geom_hline(yintercept = c(-1,1), col = "red") +
  ylim(-10,10) +
  xlim(2.5,16) +
  theme_bw() +
  theme(axis.title = element_text(size = 18), plot.title = element_text(size = 22), panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) +
  labs(x = "Average logCPM", title = "Lichenizing Fungus", colour = "Differential Expression")
myco_VL
ggsave("mycoVL_ggplot_volcano.pdf", myco_VL, width = 6.75, height = 5.21)

#Fig. 2A Differential expression between water vapor and liquid water hydrated trebouxiophyceae transcriptome. 
photo_VL <- ggplot(subset(model_results, Comparison == "Vapor_Liquid" & Biont == "Photobiont"), aes(x = Av.logCPM, y = logFC, col = diffexpressed)) +
  geom_point(aes(size = diffexpressed)) +
  scale_color_manual(values = "black") +
  scale_size_manual(values=c(1.5)) +
  geom_hline(yintercept = c(-1,1), col = "red") +
  ylim(-10,10) +
  xlim(2.5,16) +
  theme_bw() +
  theme(axis.title = element_text(size = 18), plot.title = element_text(size = 22), panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) +
  labs(x = "Average logCPM", title = "Lichenizing Alga",colour = "Differential Expression")
photo_VL
ggsave("photobiont_ggplot_volcano.pdf", photo_VL,width = 6.75, height = 5.21)

#Fig. 2D Differential expression between water vapor and liquid water hydrated bacteria transcriptome. 
bactr_VL <- ggplot(subset(model_results, Comparison == "Vapor_Liquid" & Biont == "Bacteriabiont"), aes(x = Av.logCPM, y = logFC, col = diffexpressed)) +
  geom_point(aes(size = diffexpressed)) +
  scale_color_manual(values = c("blue", "black", "red")) +
  scale_size_manual(values=c(2.5,1.5,2.5)) +
  geom_hline(yintercept = c(-1,1), col = "red") +
  ylim(-10,10) +
  xlim(2.5,16) +
  theme_bw() +
  theme(axis.title = element_text(size = 18), plot.title = element_text(size = 22), panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) +
  labs(x = "Average logCPM", title = "Lichen Associated Bacteria", colour = "Differential Expression")
bactr_VL
ggsave("bacteria_ggplot_volcano.pdf", bactr_VL,width = 6.75, height = 5.21)

#Fig. 2C Differential expression between water vapor and liquid water hydrated basidiomycete transcriptome. 
basidio_VL <- ggplot(subset(model_results, Comparison == "Vapor_Liquid" & Biont == "Basidiobiont"), aes(x = Av.logCPM, y = logFC, col = diffexpressed)) +
  geom_point(aes(size = diffexpressed)) +
  scale_color_manual(values = "black") +
  scale_size_manual(values=c(1.5)) +
  geom_hline(yintercept = c(-1,1), col = "red") +
  ylim(-10,10) +
  xlim(2.5,16) +
  theme_bw() +
  theme(axis.title = element_text(size = 18), plot.title = element_text(size = 22), panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) +
  labs(x = "Average logCPM", title = "Lichenizing Basidios",colour = "Differential Expression")
basidio_VL
ggsave("basidios_ggplot_volcano.pdf", basidio_VL,width = 6.75, height = 5.21)



####TopGO Analysis####
library(topGO)
library(GO.db)
library(kableExtra)
fun2GO <- readMappings(file = "topGO_fungi.txt")
bac2GO <- readMappings(file = "topGO_bacteria.txt")
alg2GO <- readMappings(file = "topGO_algae.txt")
bas2GO <- readMappings(file = "topGO_basidios.txt")
lec_id <- rownames(Fun$counts)
lec2GO <- fun2GO[lec_id]
treb_id <- rownames(Alg$counts)
treb2GO <- alg2GO[treb_id]
bac_id <- rownames(Bac$counts)
bac2GO_edit <- bac2GO[bac_id]

#Vapor vs. Liquid DEGs
#fun
fun_DEG_up <- model_results[(model_results$Comparison == "Vapor_Liquid" & model_results$Biont == "Mycobiont" & model_results$diffexpressed == "UP"), 1]
fun_DEG_down <- model_results[(model_results$Comparison == "Vapor_Liquid" & model_results$Biont == "Mycobiont" & model_results$diffexpressed == "DOWN"), 1]
#bacteria
bac_DEG_up <- model_results[(model_results$Comparison == "Vapor_Liquid" & model_results$Biont == "Bacteriabiont" & model_results$diffexpressed == "UP"), 1]
bac_DEG_down <- model_results[(model_results$Comparison == "Vapor_Liquid" & model_results$Biont == "Bacteriabiont" & model_results$diffexpressed == "DOWN"), 1]
#algae
alg_DEG_up <- model_results[(model_results$Comparison == "Dry_Vapor" & model_results$Biont == "Photobiont" & model_results$diffexpressed == "UP"), 1]
alg_DEG_down <- model_results[(model_results$Comparison == "Dry_Vapor" & model_results$Biont == "Photobiont" & model_results$diffexpressed == "DOWN"), 1]


#Test for enrichment in vapor vs liquid fungal DEGs
funNames <- names(lec2GO) 
#Up and Down regulated genes
geneList <- factor(as.integer(funNames %in% c(fun_DEG_down, fun_DEG_up)))
names(geneList) <- funNames
GOdata <- new("topGOdata", ontology = "BP", allGenes = geneList, annot = annFUN.gene2GO, gene2GO = lec2GO)
resultFis <- runTest(GOdata, algorithm = "classic", statistic = "fisher")
resultWeight <- runTest(GOdata, algorithm = "weight01", statistic = "fisher")
fun_GO_DEG_up_down <- GenTable(GOdata, classic = resultFis, weight = resultWeight, orderBy = "weight", ranksOf = "classic", topNodes = 10, numChar=1000)

#Supplemenary Table XXX
fun_GO_DEG_up_down  %>%
  kbl(caption="GO Enrichment of Differentially Expressed Lichen-forming Fungus Genes ",
      format="html",
      col.names = c("GO ID", "GO Term", "Annotated", "Significant", "Expected", "Rank in Classic", "Classic", "Weight"),
      align="r") %>%
  kable_classic(full_width = F,  html_font = "Source Sans Pro")


#Pull out all TCA cycle fungal genes
TCA <- "GO:0006099"
TCA_genes<- genesInTerm(GOdata, TCA)[[1]]
TCA_model <- model_results %>% filter(iso %in% TCA_genes)
#Pull out all sugar transporter fungal genes
polyol <- "GO:0015791"
polyol_genes <- genesInTerm(GOdata, polyol)[[1]]
poly_model <- model_results %>% filter(iso %in% polyol_genes)

a_ketoglutarate <- "GO:0006103"
a_keto_genes <- genesInTerm(GOdata, a_ketoglutarate)[[1]]


#Test for enrichment in vapor vs liquid bacteria DEGs
bacNames <- names(bac2GO_edit)
#Up and Down regulated genes
geneList <- factor(as.integer(bacNames %in% c(bac_DEG_down, bac_DEG_up)))
names(geneList) <- bacNames
GOdata <- new("topGOdata", ontology = "BP", allGenes = geneList, annot = annFUN.gene2GO, gene2GO = bac2GO_edit)
resultFis <- runTest(GOdata, algorithm = "classic", statistic = "fisher")
resultWeight <- runTest(GOdata, algorithm = "weight01", statistic = "fisher")
bac_GO_DEG_up_down <- GenTable(GOdata, classic = resultFis, weight = resultWeight, orderBy = "weight", ranksOf = "classic", topNodes = 10, numChar=1000)

#Supplemenary Table XXX
bac_GO_DEG_up_down  %>%
  kbl(caption="GO Enrichment of Differentially Expressed Lichen-associated Bacteria Genes ",
      format="html",
      col.names = c("GO ID", "GO Term", "Annotated", "Significant", "Expected", "Rank in Classic", "Classic", "Weight"),
      align="r") %>%
  kable_classic(full_width = F,  html_font = "Source Sans Pro")



###Supplementary figure ### Heatmaps 
##Cluster and heatmap of selected genes
library(ComplexHeatmap)
library(InteractiveComplexHeatmap)

gene_clust <- function(cpm, genes){
  scaled <- as.matrix(cpm) 
  scaled <- t(scale(t(scaled)))
  correlation <- cor(t(scaled), method = "pearson")
  correlated_genes <- correlation[genes,genes]
  cluster <- hclust(as.dist(1-correlated_genes), method = "complete")
  return(cluster)
}

cpm_fun <- logcpms_Fun
colnames(cpm_fun)[1] <- "iso"
rownames(cpm_fun) <- cpm_fun$iso

DEG_stats <- model_results
DEG_stats <- DEG_stats[!duplicated(DEG_stats$iso),]
DEG_stats <- separate(data = DEG_stats, col = Uniprot_ID, into = c("gene", "organism"), sep = "_")
DEG_stats <- DEG_stats[,c(1,7)]
column <- c("dry_1", "dry_2", "dry_3", "dry_4", "dry_5", "vapor_1", "vapor_2", "vapor_3", "vapor_4", "vapor_5", "liquid_1", "liquid_2", "liquid_3", "liquid_4", "liquid_5")

#Set up matrix
TCA_matrix <- as.matrix(cpm_fun[TCA_genes,-c(1,17)])
scaled_TCA <- t(scale(t(TCA_matrix)))
#Cluster resp genes
TCA_gene_clust <- gene_clust(cpm_fun[,-c(1,17)], TCA_genes) 
#Heatmap of respiration genes, hierarchically clustered
#get gene labels
gene_rows <- left_join(cpm_fun, DEG_stats)
rownames(gene_rows) <- gene_rows$iso
gene_rows <- gene_rows[TCA_genes,]
labels <- gene_rows$gene
#Heatmap
png("tca_heatmap.png",width=3.25,height=3.5,units="in",res=1200)
r <- Heatmap(scaled_TCA, column_order = column, show_row_names = TRUE, row_labels = labels, name = "Expression", column_names_gp = gpar(fontsize = 7), row_names_gp = gpar(fontsize = 7))
draw(r)
dev.off()

#Set up matrix
polyol_matrix <- as.matrix(cpm_fun[polyol_genes,-c(1,17)])
scaled_polyol <- t(scale(t(polyol_matrix)))
#Cluster resp genes
polyol_gene_clust <- gene_clust(cpm_fun[,-c(1,17)], polyol_genes) 
#Heatmap of respiration genes, hierarchically clustered
#get gene labels
gene_rows <- left_join(cpm_fun, DEG_stats)
rownames(gene_rows) <- gene_rows$iso
gene_rows <- gene_rows[polyol_genes,]
labels <- gene_rows$gene
#Heatmap
png("polyol_heatmap.png",width=3.25,height=3.5,units="in",res=1200)
r <- Heatmap(scaled_polyol, column_order = column, show_row_names = TRUE, row_labels = labels, name = "Expression", column_names_gp = gpar(fontsize = 7), row_names_gp = gpar(fontsize = 7))
draw(r)
dev.off()
