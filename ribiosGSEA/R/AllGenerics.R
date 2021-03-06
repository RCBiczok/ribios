setGeneric("gsCategory", function(object, ...) standardGeneric("gsCategory"))
setGeneric("gsName", function(object, ...) standardGeneric("gsName"))
setGeneric("gsDesc", function(object, ...) standardGeneric("gsDesc"))
setGeneric("gsGenes", function(object,...) standardGeneric("gsGenes"))
setGeneric("gsGeneCount", function(object,...) standardGeneric("gsGeneCount"))
setGeneric("gsGeneValues", function(object) standardGeneric("gsGeneValues"))
setGeneric("gsGenes<-", function(object,value) standardGeneric("gsGenes<-"))
setGeneric("gsGeneValues<-", function(object,value) standardGeneric("gsGeneValues<-"))
setGeneric("isGseaCoreEnrich", function(object) standardGeneric("isGseaCoreEnrich"))
setGeneric("gseaES", function(object) standardGeneric("gseaES"))
setGeneric("gseaNES", function(object) standardGeneric("gseaNES"))
setGeneric("gseaNP", function(object) standardGeneric("gseaNP"))
setGeneric("gseaFDR", function(object) standardGeneric("gseaFDR"))
setGeneric("gseaFWER", function(object) standardGeneric("gseaFWER"))

setGeneric("gsGeneIndices", function(object) standardGeneric("gsGeneIndices"))
setGeneric("gseaESprofile", function(object) standardGeneric("gseaESprofile"))
setGeneric("gseaCoreEnrichThr", function(object) standardGeneric("gseaCoreEnrichThr"))
setGeneric("gseaCoreEnrichGenes", function(object) standardGeneric("gseaCoreEnrichGenes"))
setGeneric("annoGseaResItem", function(object, ...) standardGeneric("annoGseaResItem"))
##setGeneric("gseaRes", function(object) standardGeneric("gseaRes"))
setGeneric("annoGseaRes", function(object) standardGeneric("annoGseaRes"))

setGeneric("GeneSet", function(category, name, desc, genes, ...) standardGeneric("GeneSet"))

## Fisher's exact test
setGeneric("hits", function(object, ...) standardGeneric("hits"))
setGeneric("pValue", function(object, ...) standardGeneric("pValue"))
setGeneric("fdrValue", function(object, ...) standardGeneric("fdrValue"))
setGeneric("gsSize", function(object, ...) standardGeneric("gsSize"))
setGeneric("gsEffSize", function(object, ...) standardGeneric("gsEffSize"))
setGeneric("minFdrValue", function(object, ...) standardGeneric("minFdrValue"))
setGeneric("minPValue", function(object, ...) standardGeneric("minPValue"))
setGeneric("isSigGeneSet", function(object, fdr,...) standardGeneric("isSigGeneSet"))
setGeneric("sigGeneSet", function(object, fdr,...) standardGeneric("sigGeneSet"))
setGeneric("sigGeneSetTable", function(object, fdr,...) standardGeneric("sigGeneSetTable"))
setGeneric("topGeneSetTable", function(object, N,...) standardGeneric("topGeneSetTable"))
setGeneric("topOrSigGeneSetTable", function(object, N, fdr, ...) standardGeneric("topOrSigGeneSetTable"))
setGeneric("fisherTest", function(genes, genesets, universe, gsName, gsCategory)
    standardGeneric("fisherTest"))

setGeneric("GeneSets", function(object, ..., category) standardGeneric("GeneSets"))
setGeneric("filterBySize", function(object,min,max) standardGeneric("filterBySize"))

## internal
setGeneric("estimateFdr", function(object,...) standardGeneric("estimateFdr"))
