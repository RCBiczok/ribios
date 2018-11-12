library(edgeR)
library(ribiosNGS)

context("sigGeneCounts")

testdata.dir <- function(x="") file.path(system.file("testdata", package="ribiosNGS"), x)

dgeResult              <- readRDS(testdata.dir("dgeResult.rds"))
dgeResultMissingGeneId <- readRDS(testdata.dir("dgeResult_missingGeneID.rds"))

correctSigGeneCounts   <- read.table(testdata.dir("correctSigGeneCounts.txt"), sep="\t", header = TRUE)
incorrectSigGeneCounts <- read.table(testdata.dir("incorrectSigGeneCounts.txt"), sep="\t",  header = TRUE)

expect_equal(sigGeneCounts(dgeResult), correctSigGeneCounts)

expect_equal(sigGeneCounts(dgeResultMissingGeneId), incorrectSigGeneCounts)
expect_equal(sigGeneCounts(dgeResultMissingGeneId, inputFeature = "FeatureID"), correctSigGeneCounts)

