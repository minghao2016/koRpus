% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/02_method_read.corp.custom.R
\name{read.corp.custom}
\alias{read.corp.custom}
\alias{read.corp.custom,kRp.text-method}
\title{Import custom corpus data}
\usage{
read.corp.custom(corpus, caseSens = TRUE, log.base = 10, ...)

\S4method{read.corp.custom}{kRp.text}(
  corpus,
  caseSens = TRUE,
  log.base = 10,
  dtm = docTermMatrix(obj = corpus, case.sens = caseSens),
  as.feature = FALSE
)
}
\arguments{
\item{corpus}{An object of class \code{kRp.text} (then the column \code{"token"} of the \code{tokens} slot is used).}

\item{caseSens}{Logical. If \code{FALSE},
      all tokens will be matched in their lower case form.}

\item{log.base}{A numeric value defining the base of the logarithm used for inverse document frequency (idf). See
\code{\link[base:log]{log}} for details.}

\item{...}{Additional options for methods of the generic.}

\item{dtm}{A document term matrix of the \code{corpus} object as generated by \code{\link[koRpus:docTermMatrix]{docTermMatrix}}.
This argument merely exists for cases where you want to re-use an already existing matrix.
By default, it is being created from the \code{corpus} object.}

\item{as.feature}{Logical,
      whether the output should be just the analysis results or the input object with
the results added as a feature. Use \code{\link[koRpus:corpusCorpFreq]{corpusCorpFreq}}
to get the results from such an aggregated object.}
}
\value{
An object of class \code{\link[koRpus:kRp.corp.freq-class]{kRp.corp.freq}}.

Depending on \code{as.feature},
      either an object of class \code{\link[koRpus:kRp.corp.freq-class]{kRp.corp.freq}},
   or an object of class \code{\link[koRpus:kRp.text-class]{kRp.text}} with the added feature \code{corp_freq} containing it.
}
\description{
Read data from a custom corpus into a valid object of class \code{\link[koRpus:kRp.corp.freq-class]{kRp.corp.freq}}.
}
\details{
The methods should enable you to perform a basic text corpus frequency analysis. That is,
      not just to
import analysis results like LCC files,
      but to import the corpus material itself. The resulting object
is of class \code{\link[koRpus:kRp.corp.freq-class]{kRp.corp.freq}},
      so it can be used for frequency analysis by
other functions and methods of this package.
}
\examples{
\dontrun{
ru.corp <- read.corp.custom("~/mydata/corpora/russian_corpus/")
}
}
\seealso{
\code{\link[koRpus:kRp.corp.freq-class]{kRp.corp.freq}}
}
\keyword{corpora}
