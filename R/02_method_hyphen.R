# Copyright 2010-2019 Meik Michalke <meik.michalke@hhu.de>
#
# This file is part of the R package koRpus.
#
# koRpus is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# koRpus is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with koRpus.  If not, see <http://www.gnu.org/licenses/>.


#' Automatic hyphenation
#'
#' These methods implement word hyphenation, based on Liang's algorithm.
#' For details, please refer to the documentation for the generic
#' \code{\link[sylly:hyphen]{hyphen}} method in the \code{sylly} package.
#'
#' @param words Either an object of class \code{\link[koRpus:kRp.text-class]{kRp.text}},
#'    or a character vector with words to be hyphenated.
#' @param hyph.pattern Either an object of class \code{\link[sylly:kRp.hyph.pat-class]{kRp.hyph.pat}}, or
#'    a valid character string naming the language of the patterns to be used. See details.
#' @param min.length Integer, number of letters a word must have for considering a hyphenation. \code{hyphen} will
#'    not split words after the first or before the last letter, so values smaller than 4 are not useful.
#' @param rm.hyph Logical, whether appearing hyphens in words should be removed before pattern matching.
#' @param corp.rm.class A character vector with word classes which should be ignored. The default value
#'    \code{"nonpunct"} has special meaning and will cause the result of
#'    \code{kRp.POS.tags(lang, tags=c("punct","sentc"), list.classes=TRUE)} to be used. Relevant only if \code{words}
#'    is a valid koRpus object.
#' @param corp.rm.tag A character vector with POS tags which should be ignored. Relevant only if \code{words}
#'    is a valid koRpus object.
#' @param quiet Logical. If \code{FALSE}, short status messages will be shown.
#' @param cache Logical. \code{hyphen()} can cache results to speed up the process. If this option is set to \code{TRUE}, the
#'    current cache will be queried and new tokens also be added. Caches are language-specific and reside in an environment,
#'    i.e., they are cleaned at the end of a session. If you want to save these for later use, see the option \code{hyph.cache.file}
#'    in \code{\link[koRpus:set.kRp.env]{set.kRp.env}}.
#' @param as A character string defining the class of the object to be returned. Defaults to \code{"kRp.hyphen"}, but can also be
#'    set to \code{"data.frame"} or \code{"numeric"}, returning only the central \code{data.frame} or the numeric vector of counted syllables,
#'    respectively. For the latter two options, you can alternatively use the shortcut methods \code{hyphen_df} or  \code{hyphen_c}.
#'    Ignored if \code{as.feature=TRUE}.
#' @param as.feature Logical, whether the output should be just the analysis results or the input object with
#'    the results added as a feature. Use \code{\link[koRpus:corpusHyphen]{corpusHyphen}} to get the results from such an aggregated object.
#'    If set to \code{TRUE}, \code{as="kRp.hyphen"} is automatically set, overwriting other setting of \code{as} with a warning.
#' @return An object of class \code{\link[koRpus:kRp.text-class]{kRp.text}}, \code{\link[sylly:kRp.hyphen-class]{kRp.hyphen}},
#'    \code{data.frame} or a numeric vector, depending on the values of the \code{as} and \code{as.feature} arguments.
#' @keywords hyphenation
# @author m.eik michalke \email{meik.michalke@@hhu.de}
#' @seealso
#'    \code{\link[sylly:read.hyph.pat]{read.hyph.pat}},
#'    \code{\link[sylly:manage.hyph.pat]{manage.hyph.pat}}
#' @references
#'  Liang, F.M. (1983). \emph{Word Hy-phen-a-tion by Com-put-er}.
#'      Dissertation, Stanford University, Dept. of Computer Science.
#'
#' [1] \url{http://tug.ctan.org/tex-archive/language/hyph-utf8/tex/generic/hyph-utf8/patterns/}
#'
#' [2] \url{http://www.ctan.org/tex-archive/macros/latex/base/lppl.txt}
#' @import methods
#' @importFrom sylly hyphen
#' @examples
#' \dontrun{
#' hyphen(tagged.text)
#' }
#' @export
#' @include 01_class_01_kRp.text.R
#' @include koRpus-internal.R
#' @aliases
#'    hyphen
#'    hyphen,kRp.text-method
#' @rdname hyphen-methods

####################################################################################
## if this signature changes, check kRp.hyphen.calc() in 'sylly' package as well! ##
####################################################################################

setMethod(
  "hyphen",
  signature(words="kRp.text"),
  function(
    words,
    hyph.pattern=NULL,
    min.length=4,
    rm.hyph=TRUE,
    corp.rm.class="nonpunct",
    corp.rm.tag=c(),
    quiet=FALSE,
    cache=TRUE,
    as="kRp.hyphen",
    as.feature=FALSE
  ){

    if(isTRUE(as.feature)){
      words_orig <- words
      if(any(as != "kRp.hyphen")){
        warning("Overwriting setting of \"as\" with \"kRp.hyphen\" because \"as.feature=TRUE\"!")
        as <- "kRp.hyphen"
      } else {}
    } else {}
    # get class kRp.text from words object
    # the internal function tag.kRp.txt() will return the object unchanged if it
    # is already tagged, so it's safe to call it with the lang set here
    tagged.text <- tag.kRp.txt(words, objects.only=TRUE)
    lang <- language(tagged.text)
    words <- tagged.txt.rm.classes(taggedText(tagged.text), lemma=FALSE,
      lang=lang, corp.rm.class=corp.rm.class, corp.rm.tag=corp.rm.tag)

    if(is.null(hyph.pattern)){
      hyph.pattern <- lang
    } else {}
    results <- sylly::hyphen(words=words, hyph.pattern=hyph.pattern, min.length=min.length,
      rm.hyph=rm.hyph, quiet=quiet, cache=cache, as=as)

    if(isTRUE(as.feature)){
      corpusHyphen(words_orig) <- results
      return(words_orig)
    } else {
      return(results)
    }
  }
)

#' @export
#' @importFrom sylly hyphen_df
#' @aliases hyphen_df,kRp.text-method
#' @rdname hyphen-methods
setMethod("hyphen_df", signature(words="kRp.text"), function(words,
    hyph.pattern=NULL, min.length=4, rm.hyph=TRUE, quiet=FALSE, cache=TRUE){

    results <- hyphen(words=words, hyph.pattern=hyph.pattern, min.length=min.length,
      rm.hyph=rm.hyph, quiet=quiet, cache=cache, as="data.frame")

    return(results)
  }
)

#' @export
#' @importFrom sylly hyphen_c
#' @aliases hyphen_c,kRp.text-method
#' @rdname hyphen-methods
setMethod("hyphen_c", signature(words="kRp.text"), function(words,
    hyph.pattern=NULL, min.length=4, rm.hyph=TRUE, quiet=FALSE, cache=TRUE){

    results <- hyphen(words=words, hyph.pattern=hyph.pattern, min.length=min.length,
      rm.hyph=rm.hyph, quiet=quiet, cache=cache, as="numeric")

    return(results)
  }
)
