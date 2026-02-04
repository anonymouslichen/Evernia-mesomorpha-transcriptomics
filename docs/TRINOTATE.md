# Trinotate in the Annotation Workflow

## Overview

**Trinotate** is a comprehensive annotation suite for transcriptomes that integrates results from multiple annotation tools. While not explicitly listed as a separate pipeline step, Trinotate was used to generate functional annotations for predicted proteins.

## Trinotate's Role

Trinotate bundles several annotation methods including:
- BLASTp vs SwissProt/UniProt
- BLAST vs Pfam
- SignalP (signal peptide prediction)
- TmHMM (transmembrane domain prediction)
- RNAMMER (rRNA prediction)
- And others

Results from these tools are loaded into a SQLite database that can be queried for downstream analysis.

## In This Pipeline

### Where Trinotate Fits
Trinotate was run after TransDecoder ORF prediction (step 05) to annotate predicted proteins with functional information.

**Workflow:**
```
05_transdecoder.sh
    ↓
    TransDecoder.Predict generates: longest_orfs.pep
    ↓
[Trinotate annotation pipeline - not scripted in this repo]
    ↓
    Trinotate SQLite database created
    ↓
SQL queries extract specific tables:
    • uniprot_accession.csv (taxonomic data)
    • longest_isoform_gene_identification.csv (gene IDs & E-values)
    ↓
10_Gene_Function_Identification.R
```

### Files Extracted from Trinotate

1. **`uniprot_accession.csv`**
   - SQL query: `uniprot_accession_sql.txt` (in `docs/`)
   - Columns: Uniprot gene ID, Organism, LinkID, NCBI Taxonomy Accession
   - Used by: `10_Gene_Function_Identification.R`

2. **`longest_isoform_gene_identification.csv`** *(likely)*
   - Columns: iso, Evalue, Gene, Organism
   - Format suggests it's from Trinotate's BLASTp results
   - Used by: `10_Gene_Function_Identification.R`

### Why Trinotate Isn't Fully Scripted Here

Trinotate has its own multi-step workflow (see [Trinotate documentation](https://github.com/Trinotate/Trinotate.github.io/wiki)). The commands would include:
1. Running component tools (BLAST, Pfam, SignalP, etc.)
2. Loading results into SQLite database
3. Generating annotation reports

These steps can vary significantly based on:
- Available annotation databases
- Computational resources
- Specific annotation needs

Rather than include a potentially outdated Trinotate pipeline, this repository focuses on:
1. The core transcriptome assembly and quantification steps
2. The specific data files extracted from Trinotate
3. The downstream differential expression analysis

## If You Need to Reproduce the Annotations

1. **Install Trinotate** following the [official documentation](https://github.com/Trinotate/Trinotate.github.io/wiki)

2. **Run Trinotate** on your TransDecoder output:
   ```bash
   # Example workflow (consult current Trinotate docs for details)
   Trinotate --init Trinotate.sqlite
   Trinotate --load_prot longest_orfs.pep
   # ... run BLAST, Pfam, etc. ...
   Trinotate --load_results
   Trinotate --report > annotation_report.xls
   ```

3. **Extract the required tables** using SQL queries similar to those in `docs/uniprot_accession_sql.txt`

## Alternative Approach

If you don't need the full Trinotate workflow, you can:
1. Run BLASTp directly against UniProt/SwissProt (E-value 0.001)
2. Parse the BLAST output to create the required CSV files
3. Proceed with the R scripts in this pipeline

This would replace Trinotate with a simpler (but less comprehensive) annotation approach.
