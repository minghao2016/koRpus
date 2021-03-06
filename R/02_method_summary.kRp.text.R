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


# internal function to produce the word class distribution table
# wclass: object@tokens[["wclass"]]
# lang:   object@lang
# abs: if not NULL, percentages will also be calculated relative to this number
wClassNoPunct <- function(wclass, lang, abs=NULL){
  word.tags <- kRp.POS.tags(lang, list.classes=TRUE, tags="words")
  wclass.num <- summary(as.factor(wclass))
  wclass.nopunct <- names(wclass.num)[names(wclass.num) %in% word.tags]
  wclass.punct <- names(wclass.num)[!names(wclass.num) %in% word.tags]
  wclass.nopunct.num <- wclass.num[wclass.nopunct]
  wclass.punct.num <- wclass.num[wclass.punct]
  wclass.nopunct.num <- wclass.nopunct.num[order(wclass.nopunct.num, decreasing=TRUE)]
  if(is.null(abs)){
    wclass.nopunct.num <- rbind(wclass.nopunct.num, 100 * wclass.nopunct.num / sum(wclass.nopunct.num))
    rownames(wclass.nopunct.num) <- c("num", "pct")
  } else {
    wclass.nopunct.num <- rbind(wclass.nopunct.num, 100 * wclass.nopunct.num / sum(wclass.nopunct.num), 100 * wclass.nopunct.num / abs)
    rownames(wclass.nopunct.num) <- c("num", "pct", "pct.abs")
  }
  wclass.nopunct.num <- t(wclass.nopunct.num)
  if(length(wclass.punct) != 0){
    if(ncol(wclass.nopunct.num) > 2){
      wclass.nopunct.num <- rbind(wclass.nopunct.num, cbind(wclass.punct.num, NA, NA))
    } else {
      wclass.nopunct.num <- rbind(wclass.nopunct.num, cbind(wclass.punct.num, NA))
    }
  } else {}
  return(wclass.nopunct.num)
}

#' @param index Either a vector indicating which rows should be considered as transformed for the statistics,
#'    or the name of a particular transformation that was previously done to the object, if more than one transformation was applied.
#'    If \code{NA}, all rows where \code{"equal"} is \code{FALSE} are used.
#'    Only valid for objects providing a \code{diff} feature.
#' @param feature A character string naming a feature present in the object, to trigger a summary regarding that feature.
#'    Currently only \code{"freq"} is implemented.
#' @export
#' @docType methods
#' @rdname summary-methods
#' @aliases summary,kRp.text-method
#' @examples
#' \dontrun{
#' tagged.results <- treetag("~/my.data/sample_text.txt", treetagger="manual", lang="en",
#'    TT.options=list(path="~/bin/treetagger", preset="en"))
#' summary(tagged.results)
#' }
#' @include 01_class_01_kRp.text.R
#' @include 02_method_summary.kRp.lang.R
setMethod("summary", signature(object="kRp.text"), function(object, index=NA, feature=NULL){
  if(identical(feature, "freq")){
    stopifnot(hasFeature(object, "freq"))
    summary.table <- t(data.frame(
      sentences=describe(object)[["sentences"]],
      avg.sentence.length=describe(object)[["avg.sentc.length"]],
      words=describe(object)[["words"]],
      avg.word.length=describe(object)[["avg.word.length"]],
      all.characters=describe(object)[["all.chars"]],
      letters=describe(object)[["letters"]][["all"]],
      lemmata=describe(object)[["lemmata"]],
      questions=describe(object)[["questions"]],
      exclamations=describe(object)[["exclam"]],
      semicolon=describe(object)[["semicolon"]],
      colon=describe(object)[["colon"]],
      stringsAsFactors=FALSE))

    colnames(summary.table) <- "freq"

    return(summary.table)
  } else {
    # to prevent hiccups from R CMD check
    Row.names <- NULL
    desc <- describe(object)
    lang <- language(object)
    tokens <- taggedText(object)
    wclass.nopunct.num <- wClassNoPunct(wclass=tokens[["wclass"]], lang=lang)
    if(hasFeature(object, "diff")){
      wclass.orig.order <- order(order(rownames(wclass.nopunct.num)))
      if(isTRUE(is.na(index))){
        wclass.index <- !tokens[["equal"]]
      } else if(is.character(index)){
        if(length(index) > 1){
          stop(simpleError(paste0("If \"index\" is character, it must be a single value!")))
        } else {}
        diffObj <- diffText(object)
        if(index %in% colnames(diffObj[["transfmt.equal"]])){
          indexPosition <- which(colnames(diffObj[["transfmt.equal"]]) %in% index)
          if(length(indexPosition) > 1){
            warning(paste0("Index \"", index,"\" found multiple times, using last occurrence only!"), call.=FALSE)
            indexPosition <- max(indexPosition)
          } else {}
        } else {
          stop(simpleError(paste0("Transformation data \"", index,"\" not found in object!")))
        }
        wclass.index <- !diffObj[["transfmt.equal"]][[indexPosition]]
      } else {
        wclass.index <- index
      }
      wclass.nopunct.num.transfmt <- wClassNoPunct(wclass=tokens[wclass.index,"wclass"], lang=lang, abs=desc[["words"]])
      colnames(wclass.nopunct.num.transfmt) <- c("num.transfmt", "pct.transfmt", "pct.transfmt.abs")
      wclass.nopunct.num <- merge(wclass.nopunct.num, wclass.nopunct.num.transfmt, all=TRUE, by='row.names', sort=FALSE, suffixes=c("", ".transfmt"))
      # merge adds a column for row numbers, reverse that
      rownames(wclass.nopunct.num) <- wclass.nopunct.num[["Row.names"]]
      wclass.nopunct.num <- subset(wclass.nopunct.num, select=-Row.names)
      # regain original order
      wclass.nopunct.num <- wclass.nopunct.num[order(rownames(wclass.nopunct.num))[wclass.orig.order],]
      # add another column for the percentage of words of each class which were removed
      wclass.nopunct.num[["pct.transfmt.wclass"]] <- wclass.nopunct.num[["num.transfmt"]] * 100 / wclass.nopunct.num[["num"]]
      # correct for possible division by zero, NaN looks confusing here
      wclass.nopunct.num[is.nan(wclass.nopunct.num[["pct.transfmt.wclass"]]), "pct.transfmt.wclass"] <- 0
    } else {}

    cat(
    "\n  Sentences: ", desc[["sentences"]], "\n",
    "  Words:     ", desc[["words"]], " (", round(desc[["avg.sentc.length"]], digits=2), " per sentence)\n",
    "  Letters:   ", desc[["letters"]][["all"]], " (", round(desc[["avg.word.length"]], digits=2), " per word)\n\n  Word class distribution:\n\n",
    sep="")

    return(wclass.nopunct.num)
  }
})

