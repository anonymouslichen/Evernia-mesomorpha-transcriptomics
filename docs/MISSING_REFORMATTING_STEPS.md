# Missing Data Reformatting Steps

This document tracks the data reformatting steps that likely happened between
the raw tool outputs and the R script inputs, but for which we don't yet have
the explicit commands.

## 1. TransDecoder Header Parsing

**Raw TransDecoder .pep header format:**
```
>TRINITY_DN1000_c0_g1_i1.p1 GENE.TRINITY_DN1000_c0_g1~TRINITY_DN1000_c0_g1_i1 ORF TRINITY_DN1000_c0_g1_i1.p1 TRINITY_DN1000_c0_g1_i1:1-285(+) len:95 TRINITY_DN1000_c0_g1_i1:1-285(+)
```

**Expected format in `transdecoder_ORF_IDs.txt` (read by 08_Transcript_Taxa_Identification.R):**
| gene | iso | g | len |
|------|-----|---|-----|
| TRINITY_DN1000_c0_g1 | TRINITY_DN1000_c0_g1_i1.p1 | TRINITY_DN1000_c0_g1_i1 | 285 |

**Likely parsing approach:**
```bash
# Extract headers, split on whitespace and delimiters
grep "^>" longest_orfs.pep | \
  sed 's/>//; s/ /\t/g' | \
  awk -F'\t' '{
    split($1, arr, "_i");
    gene = arr[1];
    iso = $1;
    g = $2;
    split($5, len_arr, ":");
    len = len_arr[2];
    print gene "\t" iso "\t" g "\t" len
  }' > transdecoder_ORF_IDs.txt
```

**Status:** Need to confirm actual command used

---

## 2. BLASTp nr Output Reformatting

**Raw blastp output from 06a/06b** (outfmt "6 qseqid evalue staxid"):
```
TRINITY_DN1000_c0_g1_i1.p1  1e-50  9606
```

**Expected format in `longest_isoform_blastp.txt` (read by 08_Transcript_Taxa_Identification.R):**
| gene | iso | g | m | evalue | TaxID |
|------|-----|---|---|--------|-------|
| TRINITY_DN1000_c0_g1 | TRINITY_DN1000_c0_g1_i1.p1 | TRINITY_DN1000_c0_g1_i1 | ? | 1e-50 | 9606 |

**Observations:**
- R script expects 6 columns, but blastp only outputs 3
- The `gene`, `iso`, and `g` columns are parsed from the qseqid
- The `m` column is unclear — possibly a placeholder or additional metadata?

**Likely parsing approach:**
```bash
# After 07_combine_blastp_nr.sh creates blastp_out:
awk '{
  qseqid = $1;
  evalue = $2;
  taxid = $3;
  
  # Parse gene components from qseqid
  split(qseqid, arr, "_i");
  gene = arr[1];
  iso = qseqid;
  
  # Extract "g" component (TRINITY_DN..._g#_i#)
  # This might need more complex parsing depending on exact format
  
  print gene "\t" iso "\t" g "\t" "NA" "\t" evalue "\t" taxid
}' blastp_out > longest_isoform_blastp.txt
```

**Status:** Need to confirm actual reformatting command; clarify what column `m` represents

---

## 3. Entrez Direct TaxID Lookup

**Context (from 08_Transcript_Taxa_Identification.R):**
- taxonomizr fails to resolve some TaxIDs
- These are written to `TaxID_NA.txt`
- Entrez Direct `esearch` is used to look them up manually
- Results are read from `esearch_TaxIDs.txt`

**Expected output format in `esearch_TaxIDs.txt`:**
| TaxID | superkingdom | phylum | class | order | family | genus | species |
|-------|--------------|--------|-------|-------|--------|-------|---------|

**Likely approach:**
```bash
# For each TaxID in TaxID_NA.txt:
while read taxid; do
  esearch -db taxonomy -query "txid${taxid}[Organism]" | \
  efetch -format xml | \
  xtract -pattern Taxon \
    -element TaxId ScientificName \
    -block LineageEx/Taxon -if Rank -equals superkingdom -element ScientificName \
    -block LineageEx/Taxon -if Rank -equals phylum -element ScientificName \
    -block LineageEx/Taxon -if Rank -equals class -element ScientificName \
    -block LineageEx/Taxon -if Rank -equals order -element ScientificName \
    -block LineageEx/Taxon -if Rank -equals family -element ScientificName \
    -block LineageEx/Taxon -if Rank -equals genus -element ScientificName
done < TaxID_NA.txt > esearch_TaxIDs.txt
```

**Status:** Need to confirm actual esearch command

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

| Step | Missing Command | Notes |
|------|----------------|-------|
| Parse TransDecoder headers | awk/sed to create transdecoder_ORF_IDs.txt | Can reconstruct from known format |
| Reformat blastp nr output | awk to create longest_isoform_blastp.txt | Need to clarify column `m` |
| Entrez esearch for TaxIDs | esearch/efetch/xtract command | Affects only a small subset of genes |
| Combine E. prunastri BLAST | cat command | Trivial |
| UniProt BLASTp | Full script | completely missing ? |
