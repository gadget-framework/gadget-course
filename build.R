#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly=TRUE)
project_dir <- getwd()

if (length(args) == 0) {
    stop("Usage: ./build-docs.R (directory-to-build-into | --serve)")
}

# Remove old model outputs
unlink("*_model", recursive = TRUE)

if (args[[1]] == '--serve') {
    output_dir <- tempfile(fileext = ".build-docs")
    serve_output <- TRUE
} else {
    output_dir <- args[[1]]
    serve_output <- FALSE
}

for (f in c(
        "index.Rmd",
        "introduction.Rmd",
        "Tidyverse.Rmd",
        "troubleshooting.Rmd",
        "getting_started.Rmd",
        "Gadget_installation.Rmd",
        "day2_lingmodel.Rmd",
        "day3_fitlingmodel.Rmd",
        "day4_multi_area.Rmd",
        "mfdb.Rmd",
        "stock_interactions.Rmd",
#        "suitability.Rmd",
        "")) {
    if (nchar(f) == 0) next
    rmarkdown::render(f, output_dir = output_dir, output_format = "html_document")
}

if (serve_output) {
    servr::httd(dir = output_dir, host = "0.0.0.0", port = 8000)
}
