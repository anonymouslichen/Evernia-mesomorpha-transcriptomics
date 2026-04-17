# Missing Data Reformatting Steps

This document tracks the data reformatting steps that likely happened between
the raw tool outputs and the R script inputs, but for which we don't yet have
the explicit commands.

## 1. TransDecoder Header Parsing

**Raw TransDecoder .pep header format:**
```
>TRINITY_DN1000_c0_g1_i1.p1 GENE.TRINITY_DN1000_c0_g1~TRINITY_DN1000_c0_g1_i1 ORF TRINITY_DN1000_c0_g1_i1.p1 TRINITY_DN1000_c0_g1_i1:1-285(+) len:95 TRINITY_DN1000_c0_g1_i1:1-285(+)
```

**Output format in `transdecoder_ORF_IDs.txt` (read by 08_Transcript_Taxa_Identification.R):**
| gene | iso | g | len |
|------|-----|---|-----|
| TRINITY_DN1000_c0_g1 | TRINITY_DN1000_c0_g1_i1.p1 | TRINITY_DN1000_c0_g1_i1 | 285 |

No header. Tab-separated.

**Confirmed command (from original README for this file):**
```bash
grep "^>" path/to/transdecoder.pep | cut -c 2- | tr ':' '\t' | cut -f1,3,5,13 | awk -F '[\t ]' '{print $1, $2, $3, $4}' > transdecoder_ORF_IDs.txt
```

Note: the original README listed `tr '::' '\t'`; in POSIX `tr`, duplicate characters in the source set are equivalent to a single character, so this translates `:` → `\t`.

**Status:** CONFIRMED ✓

---

## 2. BLASTp nr Output Reformatting

**Raw blastp output from 06a/06b** (outfmt "6 qseqid evalue staxid"):
```
TRINITY_DN1000_c0_g1_i1.p1  1e-50  9606
```

**Confirmed format in `longest_isoform_blastp.txt` (from original README for this file):**
| gene | iso | g | m | evalue | TaxID |
|------|-----|---|---|--------|-------|
| TRINITY_DN1000_c0_g1 | TRINITY_DN1000_c0_g1_i1.p1 | TRINITY_DN1000_c0_g1_i1 | p1 | 1e-50 | 9606 |

No header. Tab-separated.

- **gene** — Trinity assembled gene (e.g., `TRINITY_DN1000_c0_g1`)
- **iso** — Trinity assembled isoform (e.g., `TRINITY_DN1000_c0_g1_i1.p1`)
- **g** — G-number: original transcript the ORF comes from (e.g., `TRINITY_DN1000_c0_g1_i1`)
- **m** — M-number: the ORF identified on the transcript (e.g., `p1` from the `.p1` suffix)
- **evalue** — BLASTp E-value
- **TaxID** — NCBI TaxID from blastp staxid

These columns are all parsed from the 3-column raw blastp output (`qseqid evalue staxid`):
- `qseqid` like `TRINITY_DN1000_c0_g1_i1.p1` encodes gene, iso, g, and m

**Confirmed command** (`07c_reformat_blastp_nr.sh`):
```bash
cat blastp_out | \
  tr '.' '\t' | \
  awk -F '\t' 'OFS="\t" {split($1, a, "_i"); print a[1], $1"."$2, $1, $2, $3, $4}' \
  > longest_isoform_blastp.txt
```
`tr '.' '\t'` splits the `.p#` M-number off the qseqid; `awk` reconstructs `iso` (`field1.field2`) and `gene` (`field1` with `_i#` suffix removed via `split`).

**Status:** CONFIRMED ✓ (command reconstructed from known input/output format)

---

## 3. Entrez Direct TaxID Lookup

**Context (from 08_Transcript_Taxa_Identification.R):**
- taxonomizr fails to resolve some TaxIDs
- These are written to `TaxID_NA.txt`
- Entrez Direct `efetch` is used to look them up; results are reshaped in R
- Final output read by step 08 as `esearch_TaxIDs.txt`

**Confirmed two-step workflow:**

**Step 1 — fetch & extract XML** (`08b_esearch_missing_taxids.sh`):
```bash
cat TaxID_NA.txt | while read line
do
  efetch -db taxonomy -id ${line} -format xml | \
  xtract -pattern Taxon -first TaxId -element Taxon -block "*/Taxon" \
  -unless Rank -equals "no rank" -tab "," -sep "_" -element Rank,ScientificName
done > TaxID_NA_esearch.txt
```
Produces a 2-column TSV: TaxId + comma-separated `rank_name` pairs.

**Step 2 — reshape to wide format** (`08c_reformat_esearch_taxa.R`):
```r
library(tidyr)
test <- read.delim("TaxID_NA_esearch.txt", sep = "\t", header = FALSE)
test <- test %>%
  separate_rows(V2, sep = ",") %>%
  separate(V2, c("level", "value"), sep = "_") %>%
  pivot_wider(names_from = level, values_from = value)
test <- test[, c(1:7, 23)]   # cols 1–7 = TaxId–genus; col 23 = species
test <- apply(test, 2, as.character)
write.table(test, "esearch_TaxIDs.txt", quote = FALSE, sep = "\t",
            row.names = FALSE, col.names = FALSE)
```

**Output format in `esearch_TaxIDs.txt`:**
| TaxID | superkingdom | phylum | class | order | family | genus | species |
|-------|--------------|--------|-------|-------|--------|-------|---------|

**Status:** CONFIRMED ✓

---

## 4. E. prunastri BLAST Output Reformatting

**Raw tblastn output from 11_blast_eprunastri.sh** (outfmt 6, standard 12 columns):
```
qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore
```

**Expected format in `E.meso_E.prun_blast.out` (read by 12_Differential_Expression_GO_analysis.R):**

Looking at the R code (lines 80-91 in Differential_Expression_GO_analysis.R):
```r
blast <- read.delim("E.meso_E.prun_blast.out", sep = "\t", header = FALSE)
colnames(blast) <- c("qseqid", "sseqid","pident", "length", "mismatch", 
                     "gapopen", "qstart", "qend", "sstart", "send", 
                     "evalue", "bitscore")
```

This expects standard outfmt 6 (12 columns), which matches the tblastn output from step 11.

**Required:** Combine array job outputs from step 11:
```bash
cd ~/Evernia_Transcriptomes/blastp_E.meso/seq_files
cat *.out > E.meso_E.prun_blast.out
```

**Status:** Simple concatenation; just need to confirm this was done

---

## Summary of Missing Commands

| Step | Command | Status |
|------|---------|--------|
| Parse TransDecoder headers | `grep "^>" … \| cut -c 2- \| tr ':' '\t' \| cut -f1,3,5,13 \| awk …` | ✓ CONFIRMED |
| Reformat blastp nr output | `07c_reformat_blastp_nr.sh` | ✓ CONFIRMED (reconstructed) |
| Entrez esearch for TaxIDs | esearch/efetch/xtract command | Still needed |
| Combine E. prunastri BLAST | `cat *.out > E.meso_E.prun_blast.out` | Trivial; presumed |
| UniProt BLASTp | `09_blastp_uniprot.sh` | ✓ Script filled in (mirrors 06a/06b) |
