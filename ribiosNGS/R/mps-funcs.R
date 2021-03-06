## functions for MPS

sql2table <- function(sql, colnames) {
  res <- ribiosAnnotation::querydb(sql, db="bia", user="bi2", password="wolf")
  if(!missing(colnames)) {
    colnames(res) <- colnames
  }
  return(res)
}
mpsReporterCount <- function() {
  sql2table("SELECT COUNT (GENEID) FROM MPS_REPORTER",
            "count")[,1L]
}
mpsReporter <- function() {
  sql2table("SELECT GENEID, GENESYMBOL, AMPLICON, GENENAME, AMPLISEQ_LABEL FROM MPS_REPORTER",
            c("GeneID", "GeneSymbol", "Amplicon", "GeneName", "Label"))
}

mpsReporterAssocPathway <- function() {
  sql2table("SELECT DISTINCT GENEID,PATHWAY FROM MPS_REPORTER_PATHWAY", 
            c("GeneID", "Pathway"))
}

mpsReporterUpPathway <- function() {
  sql2table("SELECT DISTINCT GENEID,DIRECTIONALITY,PATHWAY FROM MPS_REPORTER_PATHWAY WHERE RELATIONSHIP='is regulated by'", 
            c("GeneID", "Directionality", "Pathway"))
}

mpsReporterUpPosPathway <- function() {
  sql2table("SELECT DISTINCT GENEID,PATHWAY FROM MPS_REPORTER_PATHWAY WHERE RELATIONSHIP='is regulated by' AND DIRECTIONALITY='positive'", 
            c("GeneID", "Pathway"))
}

mpsReporterUpNegPathway <- function() {
  sql2table("SELECT DISTINCT GENEID,PATHWAY FROM MPS_REPORTER_PATHWAY WHERE RELATIONSHIP='is regulated by' AND DIRECTIONALITY='negative'", 
            c("GeneID", "Pathway"))
}

mpsReporterDownPathway <- function() {
    sql2table("SELECT DISTINCT GENEID,DIRECTIONALITY,PATHWAY FROM MPS_REPORTER_PATHWAY WHERE RELATIONSHIP='regulates'", 
            c("GeneID", "Directionality", "Pathway"))
}

mpsReporterDownPosPathway <- function() {
  sql2table("SELECT DISTINCT GENEID,PATHWAY FROM MPS_REPORTER_PATHWAY WHERE RELATIONSHIP='regulates' AND DIRECTIONALITY='positive'", 
            c("GeneID", "Pathway"))
}

mpsReporterDownNegPathway <- function() {
  sql2table("SELECT DISTINCT GENEID,PATHWAY FROM MPS_REPORTER_PATHWAY WHERE RELATIONSHIP='regulates' AND DIRECTIONALITY='negative'", 
            c("GeneID", "Pathway"))
}

mpsReporterUpstream <- function() {
  sql2table("SELECT GENEID, UPSTREAM_GENEID, UPSTREAM_GENESYMBOL FROM MPS_REPORTER_UPSTREAM",
            c("GeneID", "UpstreamGeneID", "UpstreamGeneSymbol"))
}
mpsReporterUpstreamPos <- function() {
  sql2table("SELECT GENEID, UPSTREAM_GENEID, UPSTREAM_GENESYMBOL FROM MPS_REPORTER_UPSTREAM_POS",
            c("GeneID",  "UpstreamGeneID", "UpstreamGeneSymbol"))
}
mpsReporterUpstreamNeg <- function() {
  sql2table("SELECT GENEID, UPSTREAM_GENEID, UPSTREAM_GENESYMBOL FROM MPS_REPORTER_UPSTREAM_NEG",
            c("GeneID",  "UpstreamGeneID", "UpstreamGeneSymbol"))
}
mpsReporterDownstream <- function() {
  sql2table("SELECT GENEID,  DOWNSTREAM_GENEID, DOWNSTREAM_GENESYMBOL FROM MPS_REPORTER_DOWNSTREAM",
            c("GeneID", "DownstreamGeneID", "DownstreamGeneSymbol"))
}
mpsReporterDownstreamPos <- function() {
  sql2table("SELECT GENEID, DOWNSTREAM_GENEID, DOWNSTREAM_GENESYMBOL FROM MPS_REPORTER_DOWNSTREAM_POS",
            c("GeneID", "DownstreamGeneID", "DownstreamGeneSymbol"))
}
mpsReporterDownstreamNeg <- function() {
  sql2table("SELECT GENEID, DOWNSTREAM_GENEID, DOWNSTREAM_GENESYMBOL FROM MPS_REPORTER_DOWNSTREAM_NEG",
            c("GeneID", "DownstreamGeneID", "DownstreamGeneSymbol"))
}

mpsReporterAssocGO <- function() {
  sql2table("SELECT GENEID, GOID, GOTERM FROM MPS_REPORTER_GO_ASSOC",
            c("GeneID", "GOID", "GOTerm"))
}
mpsReporterUpGO <- function() {
  sql2table("SELECT GENEID, GOID, GOTERM FROM MPS_REPORTER_GO_UP",
            c("GeneID", "GOID", "GOTerm"))
}
mpsReporterDownGO <- function() {
  sql2table("SELECT GENEID, GOID, GOTERM FROM MPS_REPORTER_GO_DOWN",
            c("GeneID", "GOID", "GOTerm"))
}
mpsReporterAssocRCTM <- function() {
  sql2table("SELECT GENEID, PATHWAY FROM MPS_REPORTER_RCTM_ASSOC",
            c("GeneID", "Pathway"))
}
mpsReporterUpRCTM <- function() {
  sql2table("SELECT GENEID, PATHWAY FROM MPS_REPORTER_RCTM_UP",
            c("GeneID", "Pathway"))
}
mpsReporterDownRCTM <- function() {
  sql2table("SELECT GENEID, PATHWAY FROM MPS_REPORTER_RCTM_DOWN",
            c("GeneID", "Pathway"))
}

myFisher <- function(reporters, background, assoc, key) {
  ## note that some reporters and background genes may be not annotated -> they should be left out
  assoc <- subset(assoc, GeneID %in% background)
  keys <- assoc[,key]
  bg <- assoc[,"GeneID"]
  bg.by.keys <- lapply(split(bg, keys), function(x) unique(x))
  if(length(bg.by.keys)==0)
    stop("no valid keys found in myFisher: probably the index is wrong. Check the GCT file.")
  keyLevels <- names(bg.by.keys)
  sig.set <- sapply(bg.by.keys, function(x) sum(reporters %in% x))
  total.sig <- sum(reporters %in% bg)
  total.set <- sapply(bg.by.keys, length)
  grand.total <- ulen(assoc$GeneID)
  x00 <- sig.set
  x01 <- total.sig - sig.set
  x10 <- total.set - sig.set
  x11 <- grand.total - total.sig - total.set + sig.set
  xs <- lapply(seq(along=x00),
               function(x) matrix(c(x00[x], x01[x], x10[x], x11[x]), nrow=2, byrow=TRUE))
  names(xs) <- keyLevels
  fishers <- lapply(xs, function(x) fisher.test(x, alternative="greater", conf.int=FALSE, workspace=1E7))
  pVals <- sapply(fishers, function(x) x$p.value)
  FDR <- p.adjust(pVals, "BH")
  genes <- sapply(bg.by.keys, function(x) paste(intersect(reporters, x), collapse=","))
  res <- data.frame(set=keyLevels,
                    sigInSet=x00,
                    sigNotInSet=x01,
                    notSigInSet=x10,
                    notSigNotInSet=x11,
                    p=pVals, FDR=FDR, reporters=genes, row.names=NULL)
  res <- sortByCol(res, "p", decreasing=FALSE)
  return(res)
}

sigFisher <- function(edgeResult, contrast, assoc, key) {
  pos.reporters <- sigPosGene(edgeResult, contrast)
  neg.reporters <- sigNegGene(edgeResult, contrast)
  diff.reporters <- sigGene(edgeResult, contrast)
  stopifnot(length(pos.reporters)+length(neg.reporters)==length(diff.reporters))
  background <- filteredGenes(edgeResult)
  stopifnot(all(pos.reporters %in% background))
  stopifnot(all(neg.reporters %in% background))
  stopifnot(all(diff.reporters %in% background))
  posFisher <- myFisher(pos.reporters, background, assoc=assoc, key=key)
  negFisher <- myFisher(neg.reporters, background, assoc=assoc, key=key)
  diffFisher <- myFisher(diff.reporters, background, assoc=assoc, key=key)
  comb <- rbind(cbind(diffGeneExprs="pos", posFisher),
                cbind(diffGeneExprs="neg", negFisher),
                cbind(diffGeneExprs="posneg", diffFisher))
  return(comb)
}

mpsAnnotateReporters  <- function(edgeResult) {
  reporters <- mpsReporter()
  edgeResult <- annotateGenes(edgeResult, reporters, key="GeneID")
  return(edgeResult)
  
}

mpsFisher <- function(edgeResult, assoc, key) {
  contrasts <- contrastNames(edgeResult)
  fisherRes <- lapply(contrasts, function(x)
                      sigFisher(edgeResult, x, assoc, key))
  res <- do.call(rbind, fisherRes)
  res$contrast <- rep(contrasts, sapply(fisherRes, nrow))
  res <- putColsFirst(res, "contrast")
  return(res)
}

assocPathwayFishers <- function(edgeResult) {
  mpsFisher(edgeResult,
            mpsReporterAssocPathway(),
            "Pathway")
}
upPathwayFishers <- function(edgeResult) {
  mpsFisher(edgeResult,
            mpsReporterUpPathway(),
            "Pathway")
}
upPosPathwayFishers <- function(edgeResult) {
  mpsFisher(edgeResult,
            mpsReporterUpPosPathway(),
            "Pathway")
}
upNegPathwayFishers <- function(edgeResult) {
  mpsFisher(edgeResult,
            mpsReporterUpNegPathway(),
            "Pathway")
}
downPathwayFishers <- function(edgeResult) {
  mpsFisher(edgeResult,
            mpsReporterDownPathway(),
            "Pathway")
}
downPosPathwayFishers <- function(edgeResult) {
  mpsFisher(edgeResult,
            mpsReporterDownPosPathway(),
            "Pathway")
}
downNegPathwayFishers <- function(edgeResult) {
  mpsFisher(edgeResult,
            mpsReporterDownNegPathway(),
            "Pathway")
}

upGeneFishers <- function(edgeResult) {
  mpsFisher(edgeResult,
            mpsReporterUpstream(),
            "UpstreamGeneSymbol")
}
upPosGeneFishers <- function(edgeResult) {
  mpsFisher(edgeResult,
            mpsReporterUpstreamPos(),
            "UpstreamGeneSymbol")
}
upNegGeneFishers <- function(edgeResult) {
  mpsFisher(edgeResult,
            mpsReporterUpstreamNeg(),
            "UpstreamGeneSymbol")
}
downGeneFishers <- function(edgeResult) {
  mpsFisher(edgeResult,
            mpsReporterDownstream(),
            "DownstreamGeneSymbol")
}
downPosGeneFishers <- function(edgeResult) {
  mpsFisher(edgeResult,
            mpsReporterDownstreamPos(),
            "DownstreamGeneSymbol")
}
downNegGeneFishers <- function(edgeResult) {
  mpsFisher(edgeResult,
            mpsReporterDownstreamNeg(),
            "DownstreamGeneSymbol")
}

assocRCTMFishers <- function(edgeResult) {
  mpsFisher(edgeResult,
            mpsReporterAssocRCTM(),
            "Pathway")
}
upRCTMFishers <- function(edgeResult) {
  mpsFisher(edgeResult,
            mpsReporterUpRCTM(),
            "Pathway")
}
downRCTMFishers <- function(edgeResult) {
  mpsFisher(edgeResult,
            mpsReporterDownRCTM(),
            "Pathway")
}

## GO
assocGOFishers <- function(edgeResult) {
  mpsFisher(edgeResult,
            mpsReporterAssocGO(),
            "GOTerm")
}
upGOFishers <- function(edgeResult) {
  mpsFisher(edgeResult,
            mpsReporterUpGO(),
            "GOTerm")
}
downGOFishers <- function(edgeResult) {
  mpsFisher(edgeResult,
            mpsReporterDownGO(),
            "GOTerm")
}

## to refactor!
doFisher <- function(edgeRes) {
  doLog("Perform gene-level analysis", level=1)
  doLog("Perform upstream regulator analysis", level=2)
  upGenes <- upGeneFishers(edgeRes)
  write.table(upGenes, "upGenes.txt")
  
  doLog("Perform upstream regulator analysis using positively regulated reporters", level=3)
  upPosGenes <- upPosGeneFishers(edgeRes)
  write.table(upPosGenes, "upPosGenes.txt")
  
  doLog("Perform upstream regulator analysis using negatively regulated reporters", level=3)
  upNegGenes <- upNegGeneFishers(edgeRes)
  write.table(upNegGenes, "upNegGenes.txt")
  
  doLog("Perform downstream regulator analysis", level=2)
  downGenes <- downGeneFishers(edgeRes)
  write.table(downGenes, "downGenes.txt")
  
  doLog("Perform downstream regulator analysis using positively regulated reporters", level=3)
  downPosGenes <- downPosGeneFishers(edgeRes)
  write.table(downPosGenes, "downPosGenes.txt")
  
  doLog("Perform downstream regulator analysis using negatively regulated reporters", level=3)
  downNegGenes <- downNegGeneFishers(edgeRes)
  write.table(downNegGenes, "downNegGenes.txt")
  
  doLog("Perform pathway-level analysis", level=1)
  doLog("Perform pathway association analysis", level=2)
  assocPathway <- assocPathwayFishers(edgeRes)
  write.table(assocPathway, "assocPathway.txt")
  
  doLog("Perform upstream pathway analysis", level=2)
  upPathway <- upPathwayFishers(edgeRes)
  write.table(upPathway, "upPathway.txt")
  
  doLog("Perform upstream pathway analysis using positively regulated genes", level=3)
  upPosPathway <- upPosPathwayFishers(edgeRes)
  write.table(upPosPathway, "upPosPathway.txt")
  
  doLog("Perform upstream pathway analysis using negatively regulated genes", level=3)
  upNegPathway <- upNegPathwayFishers(edgeRes)
  write.table(upNegPathway, "upNegPathway.txt")
  
  doLog("Perform downstream pathway analysis", level=2)
  downPathway <- downPathwayFishers(edgeRes)
  write.table(downPathway, "downPathway.txt")
  
  doLog("Perform downstream pathway analysis using positively regulated genes", level=3)
  downPosPathway <- downPosPathwayFishers(edgeRes)
  write.table(downPosPathway, "downPosPathway.txt")
  
  doLog("Perform downstream pathway analysis using negatively regulated genes", level=3)
  downNegPathway <- downNegPathwayFishers(edgeRes)
  write.table(downNegPathway, "downNegPathway.txt")

  
  doLog("Perform reactome-based analysis", level=1)
  doLog("Perform association reactome pathway analysis", level=2)
  assocRCTM <- assocRCTMFishers(edgeRes)
  write.table(assocRCTM, "assocRCTM.txt")
  
  doLog("Perform upstream reactome pathway analysis", level=2)
  upRCTM <- upRCTMFishers(edgeRes)
  write.table(upRCTM, "upRCTM.txt")
  
  doLog("Perform downstream reactome pathway analysis", level=2)
  downRCTM <- downRCTMFishers(edgeRes)
  write.table(downRCTM, "downRCTM.txt")
  
  doLog("Load GO-based analysis", level=1)
  doLog("Perform association GO analysis", level=2)
  assocGO <- assocGOFishers(edgeRes)
  write.table(assocGO, "assocGO.txt")
  
  doLog("Perform upstream GO analysis", level=2)
  upGO <- upGOFishers(edgeRes)
  write.table(upGO, "upGO.txt")
  
  doLog("Perform downstream GO analysis", level=2)
  downGO <- downGOFishers(edgeRes)
  write.table(downGO, "downGO.txt")
}

