# InvertypeR
Source code for all three components of the InvertypeR process:
1. Composite file creation
2. InvertypeR genotyping (soon to be an R package)
3. Inversion visualization (with links to the UCSC Genome Browser)

Composite file creation
-----------------------
Dependencies:
  - *tool (version we use)*
  - samtools (1.10)
  - freebayes (1.3.2)
  - bcftools (1.10.2)
  - R (3.5.1)
  - R package GenomicRanges (1.34.0)
  - R package [breakpointR](https://bioconductor.org/packages/release/bioc/html/breakpointR.html) (1.5.1)
  - R package [StrandPhaseR](https://github.com/daewoooo/StrandPhaseR) (0.99)
  - R package BSgenome.Hsapiens.UCSC.hg38 (1.4.1)

These scripts create two Strand-seq composite files, given a set of single-cell Strand-seq libraries for an individual (BAM format, indexed). Poor-quality libraries must first be removed. To create the Watson-Watson (WW or WWCC) composite file, run "bash master_WWCC_composite.sh" in the directory containing the single-cell BAM files. Same goes for the Watson-Crick (WC or WCCW) composite file: run "bash master_WCCW_composite.sh". Both master scripts must first be edited to set user-specific variables (e.g. # threads, directory containing scripts). 

InvertypeR genotyping
-----------------------
Dependencies:
  - *tool (version we use)*
  - R (3.5.1)
  - R package GenomicAlignments (1.18.1)

This series of functions is run using the invertyper() wrapper function, which takes as arguments two composite BAM files (as above), a set of intervals to genotype, priors, and a few other options (Soon to be an R package; see source code for now). 

Inversion visualization
-----------------------
Dependencies:
  - *tool (version we use)*
  - R (3.5.1)
  - R package dplyr (0.8.5)
  - R package gridExtra (2.3)
  - R package ggplot2 (3.3.0)
  - R package data.table (1.12.8)
  - R package psych (2.0.9)
  - ImageMagick (7.0.10-0)
  - python package img2pdf (0.4.0)
  - PDF-API2 (2.038)
  - LWP (6.49)
  
(Courtesy of Victor Guryev and Carl-Adam Mattsson)
These scripts can be found [here](https://github.com/mattssca/haploplotR), along with more detailed instructions. In brief, clone the repository, put an InvertypeR output file in the "in" directory, and run "bash haploplot_run.sh". A PDF ideogram linked to a UCSC Genome Browser session will be created automatically. To visualize the Strand-seq data as well, upload the BreakpointR browserfiles produced during composite file creation to the genome browser as well. 
