This file contains taxonomic data for each uniprot gene_organism. This file was retrieved from the Trinotate sql database with the following sql command:

.headers on
.mode csv
.output uniprot_accession.csv
SELECT  UniprotIndex.Accession, UniprotIndex.LinkID, TaxonomyIndex.TaxonomyValue FROM UniprotIndex
JOIN TaxonomyIndex ON UniprotIndex.LinkID = TaxonomyIndex.NCBITaxonomyAccession;
.quit


File contains no header. 
Col 1: Uniprot gene identifier
Col 2: Organism
Col 3: Link ID, ID that links Uniprot organism to NCBI taxonomy
Col 4: NCBI Taxonomy Accession