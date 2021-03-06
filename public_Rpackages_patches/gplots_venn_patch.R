## venn diagram (ported from gplots, which has the bug that when using with PDF options, blank pages inserted)
drawVennDiagram.patch <- function (data, small = 0.7, showSetLogicLabel = FALSE, simplify = FALSE)  {
    numCircles <- NA
    data.colnames <- NULL
    data.rownames <- NULL
    if (is.matrix(data)) {
        numCircles <- ncol(data) - 1
        data.colnames <- colnames(data)[2:(ncol(data))]
        data.rownames <- rownames(data)
    }
    else {
        cat("Testing only, presuming first argument to specify", 
            "the number of circles to draw.\n")
        numCircles <- data
    }
    m <- (0:(-1 + 2^numCircles))
    if (!is.matrix(data)) {
        data <- t(sapply(X = m, FUN = function(v) {
            l <- gplots:::baseOf(v, 2, numCircles)
            return(l)
        }))
        for (i in m) {
            n <- paste(data[i + 1, ], collapse = "")
            if (is.null(data.rownames)) {
                data.rownames <- n
            }
            else {
                data.rownames <- c(data.rownames, n)
            }
        }
        data <- cbind(sample(1:100, size = 2^numCircles, replace = TRUE), 
            data)
        rownames(data) <- data.rownames
        data.colnames <- LETTERS[1:numCircles]
        colnames(data) <- c("num", data.colnames)
    }
    if ((2 <= numCircles && numCircles <= 3) || (4 == numCircles && 
        simplify)) {
        degrees <- 2 * pi/numCircles * (1:numCircles)
        s <- 1/8
        x <- sapply(degrees, FUN = sin) * s + 0.5
        y <- sapply(degrees, FUN = cos) * s + 0.5
        if (!require(grid)) {
            stop("Need access to 'grid' library.")
        }
        grid.newpage()
        grid.circle(x, y, 3/12, name = "some name")
        distFromZero <- rep(NA, 2^numCircles)
        degrees <- rep(NA, 2^numCircles)
        degrees[(2^numCircles)] <- 0
        distFromZero[(2^numCircles)] <- 0
        for (i in 0:(numCircles - 1)) {
            distFromZero[2^i + 1] <- 4/12
            degrees[2^i + 1] <- 2 * pi/numCircles * i
            d <- degrees[2^i + 1]
            grid.text(label = data.colnames[numCircles - i], 
                x = sin(d) * 5/12 + 0.5, y = cos(d) * 5/12 + 
                  0.5, rot = 0)
        }
        if (4 == numCircles) {
            for (i in 0:(numCircles - 1)) {
                distFromZero[2^i + 2^((i + numCircles - 1)%%numCircles) + 
                  2^((i + 1)%%numCircles) + 1] <- 2/12
                degrees[2^i + 2^((i + numCircles - 1)%%numCircles) + 
                  2^((i + 1)%%numCircles) + 1] <- degrees[2^i + 
                  1]
            }
        }
        if (3 <= numCircles) {
            for (i in 0:(numCircles - 1)) {
                distFromZero[(2^i + 2^((i + 1)%%numCircles)) + 
                  1] <- 3/12
                if (i == (numCircles - 1)) {
                  degrees[(2^i + 2^((i + 1)%%numCircles)) + 1] <- (degrees[2^i + 
                    1] + 2 * pi + degrees[1 + 1])/2
                }
                else {
                  degrees[(2^i + 2^((i + 1)%%numCircles)) + 1] <- (degrees[2^i + 
                    1] + degrees[2^((i + 1)%%numCircles) + 1])/2
                }
            }
        }
        for (i in 1:2^numCircles) {
            n <- paste(gplots:::baseOf((i - 1), 2, numCircles), collapse = "")
            v <- data[n, 1]
            d <- degrees[i]
            if (1 == length(d) && is.na(d)) {
                if (v > 0) 
                  warning("Not shown: ", n, "is", v, "\n")
            }
            else {
                l <- distFromZero[i]
                x <- sin(d) * l + 0.5
                y <- cos(d) * l + 0.5
                l <- v
                if (showSetLogicLabel) 
                  l <- paste(n, "\n", v, sep = "")
                grid.text(label = l, x = x, y = y, rot = 0)
            }
        }
    }
    else if (4 <= numCircles && numCircles <= 5 && !simplify) {
      ##grid.newpage()
        relocate_elp <- function(e, alpha, x, y) {
            phi = (alpha/180) * pi
            xr = e[, 1] * cos(phi) + e[, 2] * sin(phi)
            yr = -e[, 1] * sin(phi) + e[, 2] * cos(phi)
            xr = x + xr
            yr = y + yr
            return(cbind(xr, yr))
        }
        lab <- function(identifier, data, showLabel = showSetLogicLabel) {
            r <- data[identifier, 1]
            if (showLabel) {
                return(paste(identifier, r, sep = "\n"))
            }
            else {
                return(r)
            }
        }
        plot(c(0, 400), c(0, 400), type = "n", axes = F, ylab = "", 
            xlab = "")
        if (4 == numCircles) {
            elps = cbind(162 * cos(seq(0, 2 * pi, len = 1000)), 
                108 * sin(seq(0, 2 * pi, len = 1000)))
            ##plot(c(0, 400), c(0, 400), type = "n", axes = F, 
            ##    ylab = "", xlab = "", add=TRUE)
            polygon(relocate_elp(elps, 45, 130, 170))
            polygon(relocate_elp(elps, 45, 200, 200))
            polygon(relocate_elp(elps, 135, 200, 200))
            polygon(relocate_elp(elps, 135, 270, 170))
            text(35, 315, data.colnames[1], cex = 1.5)
            text(138, 347, data.colnames[2], cex = 1.5)
            text(262, 347, data.colnames[3], cex = 1.5)
            text(365, 315, data.colnames[4], cex = 1.5)
            elps <- cbind(130 * cos(seq(0, 2 * pi, len = 1000)), 
                80 * sin(seq(0, 2 * pi, len = 1000)))
            text(35, 250, lab("1000", data))
            text(140, 315, lab("0100", data))
            text(260, 315, lab("0010", data))
            text(365, 250, lab("0001", data))
            text(90, 280, lab("1100", data), cex = small)
            text(95, 110, lab("1010", data))
            text(200, 50, lab("1001", data), cex = small)
            text(200, 290, lab("0110", data))
            text(300, 110, lab("0101", data))
            text(310, 280, lab("0011", data), cex = small)
            text(130, 230, lab("1110", data))
            text(245, 75, lab("1101", data), cex = small)
            text(155, 75, lab("1011", data), cex = small)
            text(270, 230, lab("0111", data))
            text(200, 150, lab("1111", data))
        }
        else if (5 == numCircles) {
            elps <- cbind(150 * cos(seq(0, 2 * pi, len = 1000)), 
                60 * sin(seq(0, 2 * pi, len = 1000)))
            polygon(relocate_elp(elps, 90, 200, 250))
            polygon(relocate_elp(elps, 162, 250, 220))
            polygon(relocate_elp(elps, 234, 250, 150))
            polygon(relocate_elp(elps, 306, 180, 125))
            polygon(relocate_elp(elps, 378, 145, 200))
            text(50, 280, data.colnames[1], cex = 1.5)
            text(150, 400, data.colnames[2], cex = 1.5)
            text(350, 300, data.colnames[3], cex = 1.5)
            text(350, 20, data.colnames[4], cex = 1.5)
            text(50, 10, data.colnames[5], cex = 1.5)
            text(61, 228, lab("10000", data))
            text(194, 329, lab("01000", data))
            text(321, 245, lab("00100", data))
            text(290, 81, lab("00010", data))
            text(132, 69, lab("00001", data))
            text(146, 250, lab("11000", data), cex = small)
            text(123, 188, lab("10100", data), cex = small)
            text(275, 152, lab("10010", data), cex = small)
            text(137, 146, lab("10001", data), cex = small)
            text(243, 268, lab("01100", data), cex = small)
            text(175, 267, lab("01010", data), cex = small)
            text(187, 117, lab("01001", data), cex = small)
            text(286, 188, lab("00110", data), cex = small)
            text(267, 235, lab("00101", data), cex = small)
            text(228, 105, lab("00011", data), cex = small)
            text(148, 210, lab("11100", data), cex = small)
            text(159, 253, lab("11010", data), cex = small)
            text(171, 141, lab("11001", data), cex = small)
            text(281, 175, lab("10110", data), cex = small)
            text(143, 163, lab("10101", data), cex = small)
            text(252, 145, lab("10011", data), cex = small)
            text(205, 255, lab("01110", data), cex = small)
            text(254, 243, lab("01101", data), cex = small)
            text(211, 118, lab("01011", data), cex = small)
            text(267, 211, lab("00111", data), cex = small)
            text(170, 231, lab("11110", data), cex = small)
            text(158, 169, lab("11101", data), cex = small)
            text(212, 139, lab("11011", data), cex = small)
            text(263, 180, lab("10111", data), cex = small)
            text(239, 232, lab("01111", data), cex = small)
            text(204, 190, lab("11111", data))
        }
    }
    else {
        stop(paste("The printing of ", numCircles, " circles is not yet supported."))
    }
}
assignInNamespace("drawVennDiagram", drawVennDiagram.patch, "gplots")
rm(drawVennDiagram.patch)
