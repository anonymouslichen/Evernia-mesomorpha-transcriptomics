# Repository Status Summary

**Last updated:** February 3, 2026

## ✅ Complete & Ready for GitHub

### Core Pipeline Scripts (Steps 01-12)
- [x] **01** - RiboDetector rRNA removal (GNU parallel wrapper)
- [x] **02** - Trinity assembly phase 1
- [x] **03** - Trinity assembly phase 2 (distributed)
- [x] **04** - Salmon transcript quantification
- [x] **05** - TransDecoder ORF prediction + FASTA splitting
- [x] **06a/06b** - BLASTp vs NCBI nr (array jobs 1-2990)
- [x] **07** - Combine BLASTp outputs
- [x] **08** - Transcript taxonomy assignment (R)
- [x] **10** - Gene function identification (R)
- [x] **11** - E. prunastri genome validation (tblastn, array 1-99)
- [x] **12** - Differential expression & GO enrichment (R)

### Documentation
- [x] `README.md` - Complete pipeline overview with status indicators
- [x] `SEQUENCING_ROUNDS.md` - Explains "_2" suffix (Round 1 = eukaryotes; Round 2 = full dataset)
- [x] `TRINOTATE.md` - Documents functional annotation via Trinotate
- [x] `PIPELINE_STATUS.md` - Tracks resolved vs outstanding issues
- [x] `MISSING_REFORMATTING_STEPS.md` - Details awk/sed reformatting between steps
- [x] `.gitignore` - Excludes large files (FASTQ, assemblies, BLAST dbs, etc.)

### Configuration
- [x] `config/SLURM.conf` - HpcGridRunner settings for Trinity phase 2
- [x] `scripts/install_R_packages.R` - Installs all CRAN + Bioconductor dependencies

### Reference Files
- [x] `docs/Evernia_Transcriptome_Full_Pipeline.sh` - Original combined pipeline notes
- [x] `docs/README_uniprot_accession.txt` - Documents Trinotate SQL extraction
- [x] `docs/uniprot_accession_sql.txt` - SQL query for UniProt taxonomy data
- [x] `docs/transdecoder_alternate.sh` - Alternate TransDecoder script (Round 2 version)

---

## ⚠️ Minor Gaps (Non-Critical)

### Step 09: Functional Annotation Source
**Current placeholder:** `scripts/09_blastp_uniprot.sh` (empty placeholder)

**What we know:**
- Functional annotations came from **Trinotate** (not standalone BLASTp)
- `longest_isoform_gene_identification.csv` was extracted from Trinotate SQLite database
- Format: `iso, Evalue, Gene, Organism`

**What's needed:**
- [ ] SQL query or extraction command used to generate `longest_isoform_gene_identification.csv`
- [ ] OR: document that this is extracted manually / via Trinotate report parsing

**Impact:** LOW — Trinotate documentation explains the workflow; missing only the specific extraction query

### Data Reformatting Commands
**Affected files:**
- `transdecoder_ORF_IDs.txt` (TransDecoder header parsing)
- `longest_isoform_blastp.txt` (BLASTp nr output reformatting)
- `esearch_TaxIDs.txt` (Entrez Direct TaxID lookup)

**Status:**
- Confirmed as awk/sed one-liners
- Likely approaches documented in `docs/MISSING_REFORMATTING_STEPS.md`
- Can be reconstructed from known input/output formats

**Impact:** LOW — Most users will have different file formats anyway and will need custom parsing

---

## 📋 Recommended Next Steps

### Before Publishing to GitHub

1. **Review file paths** in scripts 01-12:
   - Update partition names (`amdsmall`, `agsmall`, `msismall`) to generic or instructional
   - Replace `--mail-user=meye2099@umn.edu` with placeholder or remove
   - Consider adding path variables at top of scripts for easier customization

2. **Add example input files** (optional):
   - Sample `starting_files_full.txt` format (Salmon sample file)
   - Example TransDecoder header (for reformatting reference)
   - Small test dataset or link to where users can obtain similar data

3. **Resolve Step 09**:
   - Either: add the SQL query to extract `longest_isoform_gene_identification.csv`
   - Or: update placeholder script to reference Trinotate report parsing
   - Or: remove placeholder and document in README that this comes from Trinotate

4. **Add license file** (e.g., MIT, GPL, or CC-BY if preferred for data/documentation)

5. **Consider adding:**
   - `CITATION.cff` file for easy citation
   - Example SLURM submission commands in README
   - Environment setup script (module loads, conda environments)

### GitHub Repository Structure

Suggested organization:
```
Evernia_mesomorpha_transcriptome/
├── .gitignore
├── README.md
├── LICENSE
├── CITATION.cff (optional)
├── config/
│   └── SLURM.conf
├── scripts/
│   ├── 01_ribodetector.sh
│   ├── 02-12 ...
│   └── install_R_packages.R
└── docs/
    ├── SEQUENCING_ROUNDS.md
    ├── TRINOTATE.md
    ├── PIPELINE_STATUS.md
    ├── MISSING_REFORMATTING_STEPS.md
    ├── Evernia_Transcriptome_Full_Pipeline.sh (original)
    ├── README_uniprot_accession.txt
    └── uniprot_accession_sql.txt
```

---

## 🎯 Repository Goal

This repository provides a **reproducible computational workflow** for:
1. De novo metatranscriptome assembly of a lichen symbiosis
2. Symbiont-level taxonomy assignment via BLASTp + taxonomizr
3. Functional annotation via Trinotate
4. Differential expression analysis with edgeR
5. GO term enrichment and visualization

**Target audience:**
- Researchers conducting lichen transcriptomics
- General metatranscriptome studies requiring symbiont separation
- Bioinformaticians adapting workflows for non-model symbiotic systems

**Publication:**
Meyer et al. (2024). Symbionts out of sync: Decoupled physiological responses are widespread and ecologically important in lichen associations. *Science Advances*, 10, eado2783.

---

## ✨ Current Status: ~95% Complete

The repository is in excellent shape and nearly ready for publication. The remaining ~5% consists of:
- Minor documentation of reformatting commands (which users will likely customize anyway)
- Clarification on Step 09 Trinotate extraction (low priority)
- Optional polish (path variables, example files, citations)

**You can publish as-is** with a note that some intermediate reformatting steps are left as exercises for the user, or take 1-2 hours to add the polish items above.
