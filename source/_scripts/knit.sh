#! /usr/bin/Rscript

knit <- function (inputFile, outputFile) {

  # per-document figure paths
  stem <- tools::file_path_sans_ext(inputFile)
  prefix <- paste(stem, "-", sep="")
  knitr::opts_chunk$set(fig.path=file.path('../figure', prefix))

  # configure output options
  knitr::pat_md()
  knitr::opts_knit$set(out.format = 'html')
  renderOcto()

  # do the knit
  knitr::knit2html(input = inputFile, output = outputFile, options=c("use_xhtml","smartypants","mathjax","highlight_code"))
}

# adaption of knitr::render_jekyll
renderOcto <- function(extra = '') {
  knitr::render_markdown(FALSE)
  # code
  hook.c = function(x, options) {
	  prefix <- sprintf("\n\n```r", options$label)
	  suffix <- "```\n\n"
	  paste(prefix, x, suffix,sep="\n")
	}
  # output
  hook.o = function(x, options) {
	if (knitr:::output_asis(x, options))
		x
	else
		stringr::str_c('\n\n```\n',
					   x,
					   '```\n\n')
  }

  knitr::knit_hooks$set(source = hook.c, output = hook.o, warning = hook.o,
                        error = hook.o, message = hook.o)
}

# get arguments and call knit
args <- commandArgs(TRUE)
inputFile <- args[1]
outputFile <- args[2]
knit(inputFile, outputFile)