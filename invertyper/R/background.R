#' Estimates the background
#'
#' The background of a Strand-seq library is the proportion of non-directional reads, e.g., that did not incorporate BrdU and are randomly forward or reverse.
#'
#' This function chops up the genome of a WW or CC composite file (we use the term WW composite file for convenience) into bins (default size 1 Mb). Then it counts the number of forward and reverse reads
#' to calculate the fraction of that map in the reverse orientation. It uses kernel density estimation to find the mode value of that fraction. The result
#' is either the background or \code{1 - background}, and since the background should be <0.1 we can both figure out which is which and decide what the strand state 
#' of the composite file is (WW or CC). The advantage of using the mode here is that it will ignore outlier bins that contain large inversions or misaligned regions. 
#'
#'
#' @param WW_bam The path to a WW or CC composite BAM file
#' @param binsize How big should the bins be? Default 1000000.
#' @param paired_reads A Boolean: are the reads paired-end? Default TRUE.
#' @return A list: The background, the strand state of the composite file, and the number of reads in the composite file.
#'
#'
#' @export
WWCC_background <- function(WW_bam, binsize=1000000, paired_reads=TRUE){

	file <- Rsamtools::BamFile(WW_bam)
	#chromosome lengths for the first 22 chromosomes 
	chr_lengths <- Rsamtools::scanBamHeader(file)$targets[1:22]
	#Creating genomic bins, default size 1 Mb
	bins <-	GenomicRanges::tileGenome(chr_lengths, tilewidth=binsize, cut.last.tile.in.chrom=TRUE)

	#Generating parameters for countBam that are appropriate for pe or se reads
	if(paired_reads) {

		p_minus <- Rsamtools::ScanBamParam(flag = Rsamtools::scanBamFlag(isProperPair=TRUE,isUnmappedQuery=FALSE,isDuplicate=FALSE,isFirstMateRead=TRUE, isMinusStrand=TRUE),mapqFilter=10, which=bins)
		p_plus <- Rsamtools::ScanBamParam(flag = Rsamtools::scanBamFlag(isProperPair=TRUE,isUnmappedQuery=FALSE,isDuplicate=FALSE,isFirstMateRead=TRUE, isMinusStrand=FALSE),mapqFilter=10, which=bins)	
		
        } else {

		p_minus <- Rsamtools::ScanBamParam(flag = Rsamtools::scanBamFlag(isPaired=FALSE,isUnmappedQuery=FALSE,isDuplicate=FALSE, isMinusStrand=TRUE),mapqFilter=10, which=bins)
		p_plus <- Rsamtools::ScanBamParam(flag = Rsamtools::scanBamFlag(isPaired=FALSE,isUnmappedQuery=FALSE,isDuplicate=FALSE, isMinusStrand=FALSE),mapqFilter=10, which=bins)

        }

	#Counting reads by strand per bin, and using this to estimate background per bin
	num_c_bins <- Rsamtools::countBam(file, param=p_minus)[,"records"]
	num_w_bins <- Rsamtools::countBam(file, param=p_plus)[,"records"]

	num_reads <- sum(num_c_bins+num_w_bins)

	background_bins <- num_c_bins/(num_c_bins + num_w_bins)
	background_bins <- background_bins[!is.na(background_bins)]
	
	#Kernel density of the background_bins distribution 
	background_density <- density(background_bins)
	#Finding the peak of the distribution and reporting that as background, to avoid always-WC regions, inversions, etc.
	i <- which.max(background_density$y)	
	background <- background_density$x[i]

	
	#Figuring out whether we have WW or CC so the base state can be matched with the strand_state() output
	if( background < 0.1 ) {

               base_state <- "WW"

        } else if( background > 0.9 ) {

               base_state <- "CC"

        } else if( ( background > 0.3) & (background < 0.7) ) {

                stop("the input file seems to be WC/CW, not WW/CC!")

        } else {

                stop("the input file has >10% background!")

        }


	return(list(min(background, 1-background),base_state,num_reads))

}

