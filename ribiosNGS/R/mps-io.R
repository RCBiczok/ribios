#' Extract AmpliSeq target annotation from a list of read count data.frames
#' 
#' @param readCountsList A list of read count data.frames
#' 
#' The function is used internally to extract unique target annotation from multiple runs
extractTargetAnno <- function(readCountsList) {
  annos <- lapply(readCountsList, function(x) data.frame(Target=x$Target, GeneSymbol=x$Gene))
  anno <- do.call(rbind, annos)
  res <- unique(anno)
  return(res)
}

#' Merge AmpliSeq runs
#' 
#' @param readCountList A list of read count data.frames
#' @param barcodeSummaryList A list of barcode summary data.frames
#' @param runNames Character strings, run names. If \code{NULL}, a sequential number will be given.
#' 
#' The function is used internally to merge several runs into one ExpressionSet object.
mergeAmpliseqRuns <- function(readCountList, barcodeSummaryList, runNames=NULL) {
  if(is.null(runNames))
    runNames <- seq(along=readCountList)
  stopifnot(length(readCountList)==length(barcodeSummaryList))
  anno <- extractTargetAnno(readCountList)
  uniqTargets <- anno$Target
  
  phenoAnno <- cbind(Run=rep(runNames, sapply(barcodeSummaryList, nrow)),
                     do.call(rbind, barcodeSummaryList))
  colnames(phenoAnno) <- c("Run", "BarcodeID", "SampleName", 
                           "MappedReads", "ValidReads", "TargetsDetected")
  
  sampleInds <- lapply(seq(along=readCountList), function(i) {
    res <- match(barcodeSummaryList[[i]]$`Barcode ID`, colnames(readCountList[[i]]))
    if(any(is.na(res)))
      stop("Read-count matrix and barcode-summary matrix not matching: contact the developer")
    return(res)
  })
  featInds <- lapply(readCountList, function(x) {
    res <- match(uniqTargets, x$Target)
    if(any(is.na(res)))
      stop("Feature annotation error: contact the developer")
    return(res)
  })
  countMats <- sapply(seq(along=readCountList), function(i) readCountList[[i]][featInds[[i]], sampleInds[[i]]])
  countMat <- as.matrix(do.call(cbind, countMats))
  rownames(countMat) <- rownames(anno) <- uniqTargets
  colnames(countMat) <- rownames(phenoAnno) <- with(phenoAnno, paste(Run, BarcodeID, SampleName, sep="."))
  
  res <- new("ExpressionSet",
             exprs=countMat,
             phenoData=new("AnnotatedDataFrame", phenoAnno),
             featureData=new("AnnotatedDataFrame", anno))
  return(res)
}

#' Read AmpliSeq results into an ExpressionSet object
#' 
#' @param readCountFiles Character string vector, names of read count files
#' @param barcodeSummaryFiles Character string vector, names of barcode summary files
#' @param runNames Character string vector, run names
#' 
#' This function parses read count files as well as barcode summary files, 
#' and organise the data into an \code{\linkS4class{ExpressionSet}} object.
#' 
#' @examples 
#' countFiles <- system.file("extdata/AmpliSeq_files/",
#'   sprintf("ReadCountFile-%d.xls", 1:3), package="ribiosNGS")
#' barcodeFiles <- system.file("extdata/AmpliSeq_files/",
#'   sprintf("BarcodeSummaryFile-%d.xls", 1:3), package="ribiosNGS")
#' exampleAmpliSeq <- readAmpliSeq(countFiles, barcodeFiles, 
#'   runNames=c("R1", "R2", "R3"))
readAmpliSeq <- function(readCountFiles, 
                         barcodeSummaryFiles,
                         runNames=names(readCountFiles)) {
  stopifnot(length(readCountFiles)==length(barcodeSummaryFiles))
  if(!is.null(runNames)) {
    stopifnot(length(readCountFiles)==length(runNames))
  } else {
    runNames <- seq(along=readCountFileList)
  }
  readCountList <- lapply(readCountFiles, function(f) {
    fields <- readr::count_fields(f, 
                                  tokenizer=tokenizer_tsv(), n_max=1)
    colTypeStr <- paste("cc", 
                        paste(rep("i", fields-2), collapse=""),
                        sep="")
    readr::read_tsv(f, col_types=colTypeStr)
  })
  barcodeSummaryList <- lapply(barcodeSummaryFiles, function(f) {
    df <- readr::read_tsv(f, col_types="ccicc")
    if(ncol(df)==4 && identical(colnames(df), c("Barcode ID", "Sample Name", "Mapped Reads", "On Target"))) {
      df$TargetsDetected <- NA
    } else if (ncol(df)==5) {
      ## okay
    } else {
      stop("barcode summary files should have either 4 or 5 columns!")
    }
    return(df)
  })
  
  res <- mergeAmpliseqRuns(readCountList, barcodeSummaryList, runNames) 
  return(res)
}

#' Detect samples that are repeated in cherry-picking runs
#' 
#' @param eset An ExpressionSet object returned by \code{\link{readAmpliSeq}}
#' @param cherryPickingRun Character string(s), name(s) of cherry picking runs
#' 
#' @note Only valid if the sample names are unique.
#' 
#' @examples 
#' countFiles <- system.file("extdata/AmpliSeq_files/",
#'   sprintf("ReadCountFile-%d.xls", 1:3), package="ribiosNGS")
#' barcodeFiles <- system.file("extdata/AmpliSeq_files/",
#'   sprintf("BarcodeSummaryFile-%d.xls", 1:3), package="ribiosNGS")
#' exampleAmpliSeq <- readAmpliSeq(countFiles, barcodeFiles, 
#'   runNames=c("R1", "R2", "R3"))
#' summary(isCherryPickingRepeat(exampleAmpliSeq, "R3"))
isCherryPickingRepeat <- function(eset, cherryPickingRun) {
  stopifnot(cherryPickingRun %in% eset$Run)
  dupSampleNames <- eset$SampleName[duplicated(eset$SampleName)]
  isDup <- eset$SampleName %in% dupSampleNames & !eset$Run %in% cherryPickingRun
  return(isDup)
}

#' Remove samples that are repeated in cherry-picking runs
#' 
#' @param eset An ExpressionSet object returned by \code{\link{readAmpliSeq}}
#' @param cherryPickingRun Character string(s), name(s) of cherry picking runs
#' 
#' @note Only valid if the sample names are unique.
#' @examples 
#' countFiles <- system.file("extdata/AmpliSeq_files/",
#'   sprintf("ReadCountFile-%d.xls", 1:3), package="ribiosNGS")
#' barcodeFiles <- system.file("extdata/AmpliSeq_files/",
#'   sprintf("BarcodeSummaryFile-%d.xls", 1:3), package="ribiosNGS")
#' exampleAmpliSeq <- readAmpliSeq(countFiles, barcodeFiles, 
#'   runNames=c("R1", "R2", "R3"))
#' newAmpliSeq <- removeCherryPickingRepeat(exampleAmpliSeq, "R3")
removeCherryPickingRepeat <- function(eset, cherryPickingRun) {
  isDup <- isCherryPickingRepeat(eset, cherryPickingRun)
  return(eset[,!isDup])
}
