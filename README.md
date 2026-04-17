# Evernia mesomorpha Metatranscriptome Analysis Pipeline

De novo metatranscriptome assembly and differential expression analysis of the
lichen *Evernia mesomorpha*, including symbiont-level taxonomy assignment and
GO enrichment analysis.

---

**Publication**  
Meyer, A.R., Koch, N.M., McDonald, T., & Stanton, D.E. (2024).
Symbionts out of sync: Decoupled physiological responses are widespread and
ecologically important in lichen associations.
*Science Advances*, 10, eado2783.
[doi:10.1126/sciadv.ado2783](https://doi.org/10.1126/sciadv.ado2783)

**Data availability**
- Dryad: [doi:10.5061/dryad.s4mw6m9cw](https://doi.org/10.5061/dryad.s4mw6m9cw)
- BioProject: [PRJNA1051632](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA1051632)

---

## Pipeline overview

Scripts in `scripts/` are numbered in execution order.
Shell scripts (`*.sh`) are SLURM job submissions originally run on the
University of Minnesota MSI cluster.

| Step | Script | Description | Status |
|------|--------|-------------|--------|
| 01 | `01_ribodetector.sh` | Remove rRNA reads (RiboDetector) | ✓ |
| 02 | `02_trinity_assembly.sh` | De novo assembly — Phase 1 (Trinity, single-node) | ✓ |
| 03 | `03_trinity_phase2.sh` | De novo assembly — Phase 2 (Trinity, distributed via HpcGridRunner; see `config/SLURM.conf`) | ✓ |
| 04 | `04_salmon_abundance.sh` | Estimate transcript abundance per sample (Salmon via Trinity utility) → gene count matrix | ✓ |
| 05 | `05_transdecoder.sh` | Predict ORFs (TransDecoder); split peptide FASTA into 3 000 files for parallel BLAST | ✓ |
| 06 | `06a_blastp_nr_array1.sh` / `06b_blastp_nr_array2.sh` | BLASTp vs. NCBI nr — two-part SLURM array job for taxonomy-ID assignment | ✓ |
| 07 | `07_combine_blastp_nr.sh` | Concatenate per-query BLAST outputs; extract TaxIDs | ✓ |
| 07b | `07b_parse_transdecoder_headers.sh` | Parse TransDecoder peptide headers → `transdecoder_ORF_IDs.txt` | ✓ |
| 07c | `07c_reformat_blastp_nr.sh` | Reformat combined BLASTp nr output → `longest_isoform_blastp.txt` | ✓ |
| 08 | `08_Transcript_Taxa_Identification.R` | (R) Select longest isoform per gene; assign taxonomy via taxonomizr; writes `TaxID_NA.txt` for unresolved IDs — **pause here** and run 08b/08c | ✓ |
| 08b | `08b_esearch_missing_taxids.sh` | Fetch taxonomy XML for unresolved TaxIDs via Entrez Direct (`efetch` + `xtract`) → `TaxID_NA_esearch.txt` | ✓ |
| 08c | `08c_reformat_esearch_taxa.R` | (R) Reshape `TaxID_NA_esearch.txt` into wide 8-column format → `esearch_TaxIDs.txt`; then resume step 08 | ✓ |
| 09 | `09_blastp_uniprot.sh` | BLASTp vs. UniProt (release 2023_01) for gene functional annotation | x |
| 10 | `10_Gene_Function_Identification.R` | (R) Filter gene IDs by symbiont kingdom; select best E-value hit per isoform | ✓ |
| 11 | `11_blast_eprunastri.sh` | Validate *Lecanoromycetes* gene assignments against the *E. prunastri* genome (tblastn, array 1-99) | ✓ |
| 12 | `12_Differential_Expression_GO_analysis.R` | (R) edgeR differential expression; MA-style volcano plots (Fig. 2); topGO enrichment; heatmaps | ✓ |

**Legend:** ✓ = complete, ? = missing reformatting commands (see `docs/MISSING_REFORMATTING_STEPS.md`), x = script not yet located

> **Note on functional annotation:** Trinotate was used for protein functional annotation (not shown as a separate step). UniProt annotations were extracted from Trinotate's SQLite database via SQL queries. See `docs/TRINOTATE.md`.

---

## Directory structure

```
.
├── config/
│   └── SLURM.conf                          # HpcGridRunner grid config for Trinity Phase 2
├── docs/
│   └── Evernia_Transcriptome_Full_Pipeline.sh   # original combined pipeline notes
├── scripts/
│   ├── install_R_packages.R                # install all R/Bioconductor dependencies
│   └── 01–12 …                            # pipeline scripts (see table above)
└── README.md
```

---

## Requirements

### HPC & command-line software

| Software | How it was loaded / invoked | Notes |
|---|---|---|
| SLURM | cluster job scheduler | |
| Trinity v2.14.0 | `module load trinityrnaseq/2.14.0` | |
| TransDecoder | `module load trinotate` | |
| Trinotate | (via module above) | Used for functional annotation; see `docs/TRINOTATE.md` |
| BLAST+ | `module load ncbi_blast+` | |
| Salmon | via Trinity's `align_and_estimate_abundance.pl` | |
| RiboDetector | `ribodetector_cpu` (via conda) | |
| GenomeTools v1.6.2 | `~/bin/genometools-1.6.2/bin/gt` | Local install |
| Entrez Direct | `esearch` | For TaxID resolution in step 08 |

### R (step 08 onward)

Run `scripts/install_R_packages.R` to install everything, or install manually:

**CRAN:** dplyr, tidyr, tibble, ggplot2, statmod, kableExtra, stringr  
**Bioconductor:** edgeR, topGO, GO.db, ComplexHeatmap, InteractiveComplexHeatmap  
**Special:** taxonomizr — after installing, run `taxonomizr::prepareTaxDB()` once to download the NCBI taxonomy database (`accessionTaxa.sql`).

---

## Key intermediate files (not tracked in git)

| File | Produced by | Consumed by |
|---|---|---|
| `trinity_full.Trinity.fasta` | Trinity (steps 02–03) | Steps 04, 05 |
| `Trinity.gene.counts.matrix` | Salmon (step 04) | Step 08 |
| `transdecoder_ORF_IDs.txt` | TransDecoder header parsing | Step 08 |
| `longest_isoform_blastp.txt` | nr BLASTp reformatted | Step 08 |
| `gene_count_matrix_taxa.csv` | Step 08 | Step 12 |
| `longest_isoform_gene_identification.csv` | UniProt BLASTp (step 09) | Step 10 |
| `uniprot_accession.csv` | UniProt ID mapping | Step 10 |
| `best_evalue_gene_ids.csv` | Step 10 | Step 12 |
| `uniprot2go.csv` | UniProt ID mapping | Step 12 |
| `E.meso_E.prun_blast.out` | Step 11 | Step 12 |
| `accessionTaxa.sql` | `taxonomizr::prepareTaxDB()` | Step 08 |
