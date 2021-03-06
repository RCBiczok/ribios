% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/readBiokitExpression.R
\name{readBiokitExpression}
\alias{readBiokitExpression}
\title{Read Biokit Expression files}
\usage{
readBiokitExpression(files, exprsType = c("ReadCount_UniqMap", "RPKM_UniqMap",
  "ReadCount_MultiMap", "RPKM_MultiMap", "AllMappingReads"),
  ngsPipelineSampleInfoFile = NULL)
}
\arguments{
\item{files}{One or more expression files generated by the Biokit software}

\item{exprsType}{Which data types should become the exprs element of the resulting ExpressionSet.}

\item{ngsPipelineSampleInfoFile}{Sample info file used by Roche Bioinformatics NGS pipeline, a headerless TSV file including sample name, sample group, and FASTQ files, one sample per line

\code{readBiokitExpression} calls read_biokit_exprs in ribiosIO to read BioKit expression data, 
and combine data from multiple files into one ExpressionSet object

# @importFrom ribiosIO read_biokit_exprs
# @importClassesFrom Biobase ExpressionSet AnnotatedDataFrame}
}
\description{
Read Biokit Expression files
}
\examples{
biokitFiles <- system.file("extdata/biokit_expression_files",
  sprintf("biokit-output-\%d.expression", 1:4),
  package="ribiosNGS")
biokitEset <- readBiokitExpression(biokitFiles)
}
