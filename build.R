#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly=TRUE)
project_dir <- getwd()

if (length(args) == 0) {
    stop("Usage: ./build-docs.R (directory-to-build-into | --serve)")
}

# Remove old model outputs
unlink("*_model", recursive = TRUE)
unlink("_book", recursive = TRUE)
unlink("*_files", recursive = TRUE)
unlink("*_assets", recursive = TRUE)
unlink("_gadget_course", recursive = TRUE)



if (args[[1]] == '--serve') {
    output_dir <- tempfile(fileext = ".build-docs")
    serve_output <- TRUE
} else {
    output_dir <- args[[1]]
    serve_output <- FALSE
}

bookdown::serve_book(dir = ".", output_dir = "_gadget_course",
                     preview = TRUE, in_session = TRUE, quiet = FALSE,
                     host = "0.0.0.0", port = 8000)
