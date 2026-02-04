# Quick Start Guide

## For Users Wanting to Reproduce the Analysis

### 1. Clone the Repository
```bash
git clone https://github.com/YOUR_USERNAME/Evernia_mesomorpha_transcriptome.git
cd Evernia_mesomorpha_transcriptome
```

### 2. Obtain the Raw Data
Download from BioProject [PRJNA1051632](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA1051632) or Dryad [10.5061/dryad.s4mw6m9cw](https://doi.org/10.5061/dryad.s4mw6m9cw).

Place FASTQ files in your working directory (e.g., `~/Evernia_Transcriptomes/starting_files_2/`).

### 3. Set Up Software Environment

**On an HPC cluster with modules:**
```bash
module load trinityrnaseq/2.14.0
module load trinotate
module load ncbi_blast+
module load parallel
conda create -n ribodetector ribodetector
```

**Install R packages:**
```bash
Rscript scripts/install_R_packages.R
```

### 4. Customize Paths in Scripts

All scripts in `scripts/01-12` contain hardcoded paths. Update these:

```bash
# Example: update paths in all scripts at once
cd scripts/
sed -i 's|~/Evernia_Transcriptomes|/YOUR/PATH/HERE|g' *.sh
sed -i 's|meye2099@umn.edu|your.email@institution.edu|g' *.sh
```

### 5. Run the Pipeline

**Steps 01-07: Assembly & Taxonomy (shell scripts)**
```bash
# Submit SLURM jobs in order
sbatch scripts/01_ribodetector.sh
# Wait for completion, then:
sbatch scripts/02_trinity_assembly.sh
# Continue through step 07...
```

**Step 08: Taxonomy Assignment (R)**

First, prepare `transdecoder_ORF_IDs.txt` and `longest_isoform_blastp.txt` (see `docs/MISSING_REFORMATTING_STEPS.md` for guidance).

Then:
```bash
# Download NCBI taxonomy database for taxonomizr
R -e "taxonomizr::prepareSQL('accessionTaxa.sql')"

# Run the R script
Rscript scripts/08_Transcript_Taxa_Identification.R
```

**Steps 09-12: Annotation & DE Analysis**

Run Trinotate (see `docs/TRINOTATE.md`), then continue with remaining R scripts.

---

## For Users Adapting This Workflow

### Key Customization Points

1. **Organism-Specific:**
   - Step 08: Taxonomic filtering for your symbiont taxa
   - Step 11: Replace E. prunastri genome with your reference genome
   - Step 12: Adjust class names for symbiont filtering

2. **Sample Design:**
   - Step 04: Update `starting_files_full.txt` with your sample names
   - Step 12: Modify treatment contrasts for your experimental design

3. **Computational Resources:**
   - All SBATCH directives (memory, time, partition) should be adjusted for your cluster
   - Trinity may need different parallelization settings
   - BLAST array job sizes depend on your peptide count

### Recommended Workflow for Adaptation

1. **Test with subset:** Run steps 01-04 on 1-2 samples first
2. **Validate assembly:** Check Trinity stats before proceeding
3. **Test BLAST:** Try a small array job (e.g., 10 tasks) before full 3000
4. **Monitor resources:** Log memory/time usage to optimize SBATCH requests

---

## Understanding the Documentation

| File | Purpose |
|------|---------|
| `README.md` | Main overview; start here |
| `REPOSITORY_STATUS.md` | What's complete vs. what needs work |
| `SEQUENCING_ROUNDS.md` | Explains "_2" suffix in filenames |
| `TRINOTATE.md` | How functional annotation was done |
| `MISSING_REFORMATTING_STEPS.md` | Details on data format conversions |
| `PIPELINE_STATUS.md` | Tracking document (mostly for repo development) |

---

## Troubleshooting

### "File not found" errors
→ Check that paths in scripts match your directory structure. See step 4 above.

### Trinity fails with memory errors
→ Increase `--mem` in SBATCH directives or reduce `--max_memory` in Trinity command.

### BLASTp takes too long
→ Consider using diamond (faster) or a pre-filtered database for initial testing.

### R package installation fails
→ Make sure BiocManager is installed first. Some packages may need system dependencies (see package documentation).

### taxonomizr can't find accessionTaxa.sql
→ Run `taxonomizr::prepareSQL()` to download the NCBI taxonomy database (~30GB).

---

## Getting Help

1. **Check the docs** — especially `MISSING_REFORMATTING_STEPS.md` for data formatting issues
2. **Review the paper** — Meyer et al. (2024) Sci. Adv. 10, eado2783
3. **Open an issue** — Describe your problem with error messages and what you've tried

---

## Citation

If you use this pipeline, please cite:

> Meyer, A.R., Koch, N.M., McDonald, T., & Stanton, D.E. (2024). Symbionts out of sync: Decoupled physiological responses are widespread and ecologically important in lichen associations. *Science Advances*, 10, eado2783. https://doi.org/10.1126/sciadv.ado2783
