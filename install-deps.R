#!/usr/bin/env Rscript

if (!require('tidyverse')) install.packages('tidyverse')
if (!require('devtools')) install.packages('devtools')
if (!require('gadget2')) install.packages('gadget2')
if (!require('Rgadget')) devtools::install_github('Hafro/Rgadget')
if (!require('nycflights13')) install.packages('nycflights13')
#if (!require('infuser')) install.packages('https://cran.r-project.org/src/contrib/Archive/infuser/infuser_0.2.8.tar.gz', repos=NULL, type="source")
if (!require('patchwork')) install.packages('patchwork')
if (!require('magick')) install.packages('magick')
if (!require('pdftools')) install.packages('pdftools')


