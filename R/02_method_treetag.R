# Copyright 2010-2020 Meik Michalke <meik.michalke@hhu.de>
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


#' A method to call TreeTagger
#'
#' This method calls a local installation of TreeTagger[1] to tokenize and POS tag the given text.
#'
#' Note that the value of \code{lang} must match a valid language supported by \code{\link[koRpus:kRp.POS.tags]{kRp.POS.tags}}.
#' It will also get stored in the resulting object and might be used by other functions at a later point.
#' E.g., \code{treetag} is being called by \code{\link[koRpus:freq.analysis]{freq.analysis}}, which
#' will by default query this language definition, unless explicitly told otherwise. The rationale behind this
#' is to comfortably make it possible to have tokenized and POS tagged objects of various languages around
#' in your workspace, and not worry about that too much.
#'
#' @param file Either a connection or a character vector, valid path to a file, containing the text to be analyzed.
#'    If \code{file} is a connection, its contents will be written to a temporary file, since TreeTagger can't read from
#'    R connection objects.
#' @param treetagger A character vector giving the TreeTagger script to be called. If set to \code{"kRp.env"} this is got from \code{\link[koRpus:get.kRp.env]{get.kRp.env}}.
#'    Only if set to \code{"manual"}, it is assumend not to be a wrapper script that can work the given text file, but that you would like
#'    to manually tweak options for tokenizing and POS tagging yourself. In that case, you need to provide a full set of options with the \code{TT.options}
#'    parameter.
#' @param rm.sgml Logical, whether SGML tags should be ignored and removed from output
#' @param lang A character string naming the language of the analyzed corpus. See \code{\link[koRpus:kRp.POS.tags]{kRp.POS.tags}} and
#'    \code{\link[koRpus:available.koRpus.lang]{available.koRpus.lang}}for all supported languages. If set to \code{"kRp.env"} this is
#'    fetched from \code{\link[koRpus:get.kRp.env]{get.kRp.env}}.
#' @param apply.sentc.end Logical, whethter the tokens defined in \code{sentc.end} should be searched and set to a sentence ending tag.
#' @param sentc.end A character vector with tokens indicating a sentence ending. This adds to TreeTaggers results, it doesn't really replace them.
#' @param encoding A character string defining the character encoding of the input file, like  \code{"Latin1"} or \code{"UTF-8"}. If \code{NULL},
#'    the encoding will either be taken from a preset (if defined in \code{TT.options}), or fall back to \code{""}. Hence you can overwrite the preset encoding with this parameter.
#' @param TT.options A list of options to configure how TreeTagger is called. You have two basic choices: Either you choose one of the pre-defined presets
#'    or you give a full set of valid options:
#'    \itemize{
#'      \item {\code{path}} {Mandatory: The absolute path to the TreeTagger root directory. That is where its subfolders \code{bin}, \code{cmd} and \code{lib} are located.}
#'      \item {\code{preset}} {Optional: If you choose one of the pre-defined presets of one of the available language packages (like \code{"de"} for German, see
#'        \code{\link[koRpus:available.koRpus.lang]{available.koRpus.lang}} for details),
#'        you can omit all the following elements, because they will be filled with defaults. Of course this only makes sense if you have a
#'        working default installation. Note that since koRpus 0.07-1, UTF-8 is the global default encoding.}
#'      \item {\code{tokenizer}} {Mandatory: A character string, naming the tokenizer to be called. Interpreted relative to \code{path/cmd/}.}
#'      \item {\code{tknz.opts}} {Optional: A character string with the options to hand over to the tokenizer. You don't need to specify "-a"
#'        if \code{abbrev} is given. If \code{TT.tknz=FALSE}, you can pass configurational options to \code{\link[koRpus:tokenize]{tokenize}}
#'        by provinding them as a named list (instead of a character string) here.}
#'      \item {\code{pre.tagger}} {Optional: A character string with code to be run before the tagger. This code is used as-is, so you need
#'        make sure it includes the needed pipe symbols.}
#'      \item {\code{tagger}} {Mandatory: A character string, naming the tagger-command to be called. Interpreted relative to \code{path/bin/}.}
#'      \item {\code{abbrev}} {Optional: A character string, naming the abbreviation list to be used. Interpreted relative to \code{path/lib/}.}
#'      \item {\code{params}} {Mandatory: A character string, naming the parameter file to be used. Interpreted relative to \code{path/lib/}.}
#'      \item {\code{lexicon}} {Optional: A character string, naming the lexicon file to be used. Interpreted relative to \code{path/lib/}.}
#'      \item {\code{lookup}} {Optional: A character string, naming the lexicon lookup command. Interpreted relative to \code{path/cmd/}.}
#'      \item {\code{filter}} {Optional: A character string, naming the output filter to be used. Interpreted relative to \code{path/cmd/}.}
#'      \item {\code{no.unknown}} {Optional: Logical, can be used to toggle the \code{"-no-unknown"} option of TreeTagger (defaults to \code{FALSE}).}
#'      \item {\code{splitter}} {Optional: A character string, naming the splitter to be called (before the tokenizer). Interpreted relative to \code{path/cmd/}.}
#'      \item {\code{splitter.opts}} {Optional: A character string with the options to hand over to the splitter.}
#'    }
#' You can also set these options globally using \code{\link[koRpus:set.kRp.env]{set.kRp.env}},
#' and then force \code{treetag} to use them by setting \code{TT.options="kRp.env"} here. Note: 
#' If you use the \code{treetagger} setting from kRp.env and it's set to \code{TT.cmd="manual"},
#' \code{treetag} will treat \code{TT.options=NULL} like \code{TT.options="kRp.env"} 
#' automatically.
#' @param debug Logical. Especially in cases where the presets wouldn't work as expected, this switch can be used to examine the values \code{treetag}
#'    is assuming.
#' @param TT.tknz Logical, if \code{FALSE} TreeTagger's tokenzier script will be replaced by \code{koRpus}' function \code{\link[koRpus:tokenize]{tokenize}}.
#'    To accomplish this, its results will be written to a temporal file which is automatically deleted afterwards (if \code{debug=FALSE}). Note that
#'    this option only has an effect if \code{treetagger="manual"}.
#' @param format Either "file" or "obj", depending on whether you want to scan files or analyze the text in a given object, like
#'    a character vector. If the latter, it will be written to a temporary file (see \code{file}).
#' @param stopwords A character vector to be used for stopword detection. Comparison is done in lower case. You can also simply set 
#'    \code{stopwords=tm::stopwords("en")} to use the english stopwords provided by the \code{tm} package.
#' @param stemmer A function or method to perform stemming. For instance, you can set \code{SnowballC::wordStem} if you have
#'    the \code{SnowballC} package installed. As of now, you cannot provide further arguments to this function.
#' @param doc_id Character string, optional identifier of the particular document. Will be added to the \code{desc} slot, and as a factor to the \code{"doc_id"} column
#'    of the \code{tokens} slot. If \code{NA}, the document name will be used (for \code{format="obj"} a random name).
#' @param add.desc Logical. If \code{TRUE}, the tag description (column \code{"desc"} of the data.frame) will be added directly
#'    to the resulting object. If set to \code{"kRp.env"} this is fetched from \code{\link[koRpus:get.kRp.env]{get.kRp.env}}.
#' @param ... Only used for the method generic.
#' @return An object of class \code{\link[koRpus:kRp.text-class]{kRp.text}}. If \code{debug=TRUE}, prints internal variable settings and attempts to return the
#'    original output if the TreeTagger system call in a matrix.
#' @author m.eik michalke \email{meik.michalke@@hhu.de}, support for various laguages was contributed by Earl Brown (Spanish), Alberto Mirisola (Italian) and
#'    Alexandre Brulet (French).
#' @keywords misc
#' @seealso \code{\link[koRpus:freq.analysis]{freq.analysis}}, \code{\link[koRpus:get.kRp.env]{get.kRp.env}},
#' \code{\link[koRpus:kRp.text-class]{kRp.text}}
#' @references
#' Schmid, H. (1994). Probabilistic part-of-speec tagging using decision trees. In
#'    \emph{International Conference on New Methods in Language Processing}, Manchester, UK, 44--49.
#'
#' [1] \url{http://www.cis.uni-muenchen.de/~schmid/tools/TreeTagger/}
#' @export
#' @import methods
#' @docType methods
#' @rdname treetag-methods
#' @examples
#' \dontrun{
#' # first way to invoke POS tagging, using a built-in preset:
#' tagged.results <- treetag(
#'   file.path(path.package("koRpus"), "tests", "testthat", "sample_text.txt"),
#'   treetagger="manual",
#'   lang="en",
#'   TT.options=list(path="~/bin/treetagger", preset="en")
#' )
#' # second way, use one of the batch scripts that come with TreeTagger:
#' tagged.results <- treetag(
#'   file.path(path.package("koRpus"), "tests", "testthat", "sample_text.txt"),
#'   treetagger="~/bin/treetagger/cmd/tree-tagger-english",
#'   lang="en"
#' )
#' # third option, set the above batch script in an environment object first:
#' set.kRp.env(TT.cmd="~/bin/treetagger/cmd/tree-tagger-english", lang="en")
#' tagged.results <- treetag(
#'   file.path(path.package("koRpus"), "tests", "testthat", "sample_text.txt")
#' )
#'
#' # after tagging, use the resulting object with other functions in this package:
#' readability(tagged.results)
#' lex.div(tagged.results)
#' 
#' ## enabling stopword detection and stemming
#' # if you also installed the packages tm and SnowballC,
#' # you can use some of their features with koRpus:
#' set.kRp.env(TT.cmd="manual", lang="en", TT.options=list(path="~/bin/treetagger",
#'   preset="en"))
#' tagged.results <- treetag(
#'   file.path(path.package("koRpus"), "tests", "testthat", "sample_text.txt"),
#'   stopwords=tm::stopwords("en"),
#'   stemmer=SnowballC::wordStem
#' )
#'
#' # removing all stopwords now is simple:
#' tagged.noStopWords <- filterByClass(tagged.results, "stopword")
#' }
setGeneric(
  "treetag",
  def=function(
    file,
    treetagger="kRp.env",
    rm.sgml=TRUE,
    lang="kRp.env",
    apply.sentc.end=TRUE,
    sentc.end=c(".","!","?",";",":"),
    encoding=NULL,
    TT.options=NULL,
    debug=FALSE,
    TT.tknz=TRUE,
    format="file",
    stopwords=NULL,
    stemmer=NULL,
    doc_id=NA,
    add.desc="kRp.env",
    ...
  ){
    standardGeneric("treetag")
  },
  valueClass=c("kRp.text","matrix")
)

#' @export
#' @docType methods
#' @rdname treetag-methods
#' @aliases treetag,character-method
setMethod("treetag",
  signature(file="character"),
  function(
    file,
    treetagger="kRp.env",
    rm.sgml=TRUE,
    lang="kRp.env",
    apply.sentc.end=TRUE,
    sentc.end=c(".","!","?",";",":"),
    encoding=NULL,
    TT.options=NULL,
    debug=FALSE,
    TT.tknz=TRUE,
    format="file",
    stopwords=NULL,
    stemmer=NULL,
    doc_id=NA,
    add.desc="kRp.env"
  ){

    # TreeTagger uses slightly different presets on windows and unix machines,
    # so we'll need to check the OS first
    if(identical(base::.Platform[["OS.type"]], "windows")){
      unix.OS <- FALSE
    } else {
      unix.OS <- TRUE
    }

    # check on TT options
    if(identical(treetagger, "kRp.env")){
      treetagger <- get.kRp.env(TT.cmd=TRUE)
      if(all(is.null(TT.options), identical(treetagger, "manual"))){
        TT.options <- get.kRp.env(TT.options=TRUE)
      } else {}
    } else {}
    if(identical(TT.options, "kRp.env")){
      TT.options <- get.kRp.env(TT.options=TRUE)
    } else if(!is.null(TT.options) && !is.list(TT.options)){
      warning("You provided \"TT.options\", but not as a list!")
    } else {}

    if(identical(lang, "kRp.env")){
      lang <- get.kRp.env(lang=TRUE)
    } else {}
    if(identical(add.desc, "kRp.env")){
      add.desc <- get.kRp.env(add.desc=TRUE)
    } else {}

    if(identical(treetagger, "tokenize")){
      stop(simpleError("Sorry, you can't use treetag() and tokenize() at the same time!"))
    } else {}

    # TreeTagger won't be able to use a connection object, so to make these usable,
    # we have to write its content to a temporary file first
    if(identical(format, "obj")){
      takeAsFile <- dumpTextToTempfile(text=file, encoding=encoding)
      if(!isTRUE(debug)){
        on.exit(unlink(takeAsFile), add=TRUE)
      } else {}
    } else {
      # does the text file exist?
      takeAsFile <- normalizePath(file)
    }
    check.file(takeAsFile, mode="exist")

    if(is.na(doc_id)){
      doc_id <- gsub("[^[:alnum:]_\\\\.-]+", "", basename(takeAsFile))
    } else {}

    # TODO: move TT.options checks to internal function to call it here
    manual.config <- identical(treetagger, "manual")
    checkedOptions <- checkTTOptions(TT.options=TT.options, manual.config=manual.config, TT.tknz=TT.tknz)

    if(isTRUE(manual.config)){
      # specify basic paths
      TT.path <- checkedOptions[["TT.path"]]
      TT.bin <- checkedOptions[["TT.bin"]]
      TT.cmd <- checkedOptions[["TT.cmd"]]
      TT.lib <- checkedOptions[["TT.lib"]]

      # basic options
      TT.opts <- checkedOptions[["TT.opts"]]

      in.TT.options <- names(TT.options)

      have.preset <- use.splitter <- FALSE
      if(any(in.TT.options == "preset")){
        ## minimum requirements for new presets:
        #  TT.splitter        <- c() # done before tokenization
        #  TT.tokenizer       <- file.path(TT.cmd, "...")
        #  TT.tagger          <- file.path(TT.bin, "...")
        #  TT.abbrev          <- c()
        #  TT.params          <- file.path(TT.lib, "...")
        #  TT.tknz.opts       <- c()
        #  TT.lookup.command  <- c()
        #  TT.filter.command  <- c()
        preset.definition <- checkedOptions[["preset"]]
        # check for matching language definitions
        matching.lang(lang=lang, lang.preset=preset.definition[["lang"]])
        preset.list <- preset.definition[["preset"]](TT.cmd=TT.cmd, TT.bin=TT.bin, TT.lib=TT.lib, unix.OS=unix.OS)

        TT.splitter        <- preset.list[["TT.splitter"]]
        TT.splitter.opts   <- preset.list[["TT.splitter.opts"]]
        TT.tokenizer       <- preset.list[["TT.tokenizer"]]
        TT.pre.tagger      <- preset.list[["TT.pre.tagger"]]
        TT.tagger          <- preset.list[["TT.tagger"]]
        TT.abbrev          <- preset.list[["TT.abbrev"]]
        TT.params          <- preset.list[["TT.params"]]
        TT.lexicon         <- preset.list[["TT.lexicon"]]
        TT.lookup          <- preset.list[["TT.lookup"]]
        TT.filter          <- preset.list[["TT.filter"]]

        TT.tknz.opts       <- preset.list[["TT.tknz.opts"]]
        TT.lookup.command  <- preset.list[["TT.lookup.command"]]
        TT.filter.command  <- preset.list[["TT.filter.command"]]
        have.preset <- TRUE
      } else {}

      if(any(in.TT.options == "tokenizer")){
        TT.tokenizer    <- check_toggle_utf8(file_utf8=TT.options[["tokenizer"]], dir=TT.cmd)
      } else {
        TT.tokenizer    <- check_toggle_utf8(file_utf8=TT.tokenizer)
      }
      if(any(in.TT.options == "tagger")){
        TT.tagger      <- file.path(TT.bin, TT.options[["tagger"]])
      } else {}
      # check if path works
      check.file(TT.tagger, mode="exist")
      if(any(in.TT.options == "pre.tagger")){
        TT.pre.tagger  <- TT.options[["pre.tagger"]]
      } else {
        if(!isTRUE(have.preset)){
          TT.pre.tagger <- c()
        } else {}
      }
      if(any(in.TT.options == "params")){
        TT.params      <- check_toggle_utf8(file_utf8=TT.options[["params"]], dir=TT.lib)
      } else {
        TT.params      <- check_toggle_utf8(file_utf8=TT.params)
      }
      if(any(in.TT.options == "lexicon")){
        TT.lexicon     <- check_toggle_utf8(file_utf8=TT.options[["lexicon"]], dir=TT.lib)
      } else {
        TT.lexicon     <- check_toggle_utf8(file_utf8=TT.lexicon)
      }

      # check the input encoding
      input.enc <- ifelse(
        is.null(encoding),
          ifelse(
            all(identical(treetagger, "manual"), any(in.TT.options == "preset")),
              preset.definition[["encoding"]],
              ""),
          encoding)

      if(any(in.TT.options == "tknz.opts")){
        TT.tknz.opts    <- TT.options[["tknz.opts"]]
      } else {
        if(!isTRUE(have.preset)){
          TT.tknz.opts  <- c()
        } else {}
      }

      if(any(in.TT.options == "splitter")){
        TT.splitter     <- TT.options[["splitter"]]
      } else {
        if(!isTRUE(have.preset)){
          TT.splitter   <- c()
        } else {}
      }
      if(any(in.TT.options == "splitter.opts")){
        TT.splitter.opts <- TT.options[["splitter.opts"]]
      } else {
        if(!isTRUE(have.preset)){
          TT.splitter.opts <- c()
        } else {}
      }
      if(all(!identical(TT.splitter, ""), !identical(TT.splitter, c()), !is.null(TT.splitter))){
        # check if path works
        check.file(TT.splitter, mode="exist")
        use.splitter <- TRUE
      }

      if(any(in.TT.options == "abbrev")){
        TT.abbrev      <- check_toggle_utf8(file_utf8=TT.options[["abbrev"]], dir=TT.lib)
        TT.tknz.opts   <- paste(TT.tknz.opts, "-a", TT.abbrev)
      } else {
        if(all(isTRUE(have.preset), !identical(TT.abbrev, c()))){
          TT.abbrev    <- check_toggle_utf8(file_utf8=TT.abbrev)
          TT.tknz.opts <- paste(TT.tknz.opts, "-a", TT.abbrev)
        } else {
          TT.abbrev    <- eval(formals(tokenize)[["abbrev"]])
        }
      }

      ## probably replacing the tokenizer
      if(!isTRUE(TT.tknz)){
        if(!is.list(TT.tknz.opts)){
          TT.tknz.opts <- list()
        } else {}
        given.tknz.options <- names(TT.tknz.opts)
        tokenize.options <- c("split", "ign.comp", "heuristics", "heur.fix",
          "sentc.end", "detect", "clean.raw", "perl", "stopwords", "stemmer")
        for (this.opt in tokenize.options){
          if(!any(given.tknz.options == this.opt)) {
            TT.tknz.opts[[this.opt]] <- eval(formals(tokenize)[[this.opt]])
            if(isTRUE(debug)){
              message(paste0("        ", this.opt, "=", paste0(TT.tknz.opts[[this.opt]], collapse=", ")))
            } else {}
          } else {}
        }
        if(!any(given.tknz.options == "abbrev")){
          TT.tknz.opts[["abbrev"]] <- TT.abbrev
        } else {}

        # set this just for the debug printout
        TT.tokenizer  <- "koRpus::tokenize()"
        # call tokenize() and write results to tempfile
        tknz.tempfile <- tempfile(pattern="tokenize", fileext=".txt")
        tknz.results <- tokenize(
          takeAsFile,
          format="file",
          fileEncoding=input.enc,
          split=TT.tknz.opts[["split"]],
          ign.comp=TT.tknz.opts[["ign.comp"]],
          heuristics=TT.tknz.opts[["heuristics"]],
          heur.fix=TT.tknz.opts[["heur.fix"]],
          abbrev=TT.tknz.opts[["abbrev"]],
          tag=FALSE,
          lang=lang,
          sentc.end=TT.tknz.opts[["sentc.end"]],
          detect=TT.tknz.opts[["detect"]],
          clean.raw=TT.tknz.opts[["clean.raw"]],
          perl=TT.tknz.opts[["perl"]],
          stopwords=TT.tknz.opts[["stopwords"]],
          stemmer=TT.tknz.opts[["stemmer"]]
        )
        # TreeTagger can produce mixed encoded results if fed with UTF-8 in Latin1 mode
        tknz.results <- iconv(tknz.results, from="UTF-8", to=input.enc)
        on.exit(message(paste0("Assuming '", input.enc, "' as encoding for the input file. If the results turn out to be erroneous, check the file for invalid characters, e.g. em.dashes or fancy quotes, and/or consider setting 'encoding' manually.")))
        cat(paste(tknz.results, collapse="\n"), "\n", file=tknz.tempfile, sep="")
        if(!isTRUE(debug)){
          on.exit(unlink(tknz.tempfile), add=TRUE)
        } else {}
      } else {}

      if(any(in.TT.options == "lexicon")){
        if(all(!isTRUE(have.preset), !any(in.TT.options == "lookup"))){
          TT.lookup.command  <- c()
          warning("Manual TreeTagger configuration: Defined a \"lexicon\" without a \"lookup\" command, hence omitted!")
        } else {
          if(!isTRUE(have.preset)){
            TT.lookup    <- file.path(TT.cmd, TT.options[["lookup"]])
          } else {}
          TT.lexicon      <- file.path(TT.lib, TT.options[["lexicon"]])
          check.file(TT.lookup, mode="exist")
          lexiconExists <- check.file(TT.lexicon, mode="exist", stopOnFail=FALSE)
          if(isTRUE(lexiconExists)){
            TT.lookup.command  <- paste(TT.lookup, TT.lexicon, "|")
          } else {
            TT.lookup.command  <- c()
            warning(paste0("Can't find the lexicon file, hence omitted! Please ensure this path is valid:\n  ", TT.lexicon), call.=FALSE)
          }
        }
      } else {
        if(!isTRUE(have.preset)){
          TT.lookup.command  <- c()
        } else {
          if(!identical(TT.lookup.command, c())){
            check.file(TT.lookup, mode="exist")
            lexiconExists <- check.file(TT.lexicon, mode="exist", stopOnFail=FALSE)
            if(!isTRUE(lexiconExists)){
              TT.lookup.command  <- c()
              warning(paste0("Can't find the lexicon file, hence omitted! Please ensure this path is valid:\n  ", TT.lexicon), call.=FALSE)
            } else {}
          } else {}
        }
      }

      if(any(in.TT.options == "filter")){
        TT.filter      <- file.path(TT.cmd, TT.options[["filter"]])
        TT.filter.command  <- paste("|", TT.filter)
      } else {
        if(!isTRUE(have.preset)){
          TT.filter.command  <- c()
        } else {}
      }

      # create system call for unix and windows
      if(isTRUE(unix.OS)){
        if(isTRUE(TT.tknz)){
          TT.call.file <- paste0("\"", takeAsFile, "\"")
          if(isTRUE(use.splitter)){
            TT.splitter <- paste(TT.splitter, TT.call.file, TT.splitter.opts)
            TT.call.file <- ""
          } else {}
          sys.tt.call <- paste(TT.splitter, TT.tokenizer, TT.tknz.opts, TT.call.file, "|",
            TT.lookup.command, TT.pre.tagger, TT.tagger, TT.opts, TT.params, TT.filter.command)
        } else {
          sys.tt.call <- paste("cat ", tknz.tempfile, "|",
            TT.lookup.command, TT.pre.tagger, TT.tagger, TT.opts, TT.params, TT.filter.command)
        }
      } else {
        if(isTRUE(TT.tknz)){
          TT.call.file <- winPath(paste0("\"", takeAsFile, "\""))
          if(isTRUE(use.splitter)){
            TT.splitter <- paste(winPath(TT.splitter), TT.call.file, TT.splitter.opts)
            TT.call.file <- ""
          } else {}
          sys.tt.call <- paste(TT.splitter, "perl ", winPath(TT.tokenizer), TT.tknz.opts, TT.call.file, "|",
            winPath(TT.lookup.command), TT.pre.tagger, winPath(TT.tagger), winPath(TT.params), TT.opts, TT.filter.command)
        } else {
          sys.tt.call <- paste("type ", winPath(tknz.tempfile), "|",
            winPath(TT.lookup.command), TT.pre.tagger, winPath(TT.tagger), winPath(TT.params), TT.opts, TT.filter.command)
        }
      }

    } else {
      input.enc <- ifelse(
        is.null(encoding),
          "",
          encoding)

      check.file(treetagger, mode="exec")

      sys.tt.call <- paste(treetagger, takeAsFile)
    }

    ## uncomment for debugging
    if(isTRUE(debug)){
      if(isTRUE(manual.config)){
        message(paste(
          if(isTRUE(use.splitter)){
          paste("
          TT.splitter: ", TT.splitter,"
          TT.splitter.opts: ", TT.splitter.opts)
          },"
          TT.tokenizer: ",TT.tokenizer,
          ifelse(isTRUE(TT.tknz),
            paste0("\n\t\t\t\tTT.tknz.opts: ",TT.tknz.opts),
            paste0("\n\t\t\t\ttempfile: ",tknz.tempfile)),"
          file: ",takeAsFile,"
          TT.lookup.command: ",TT.lookup.command,"
          TT.pre.tagger: ", TT.pre.tagger,"
          TT.tagger: ",TT.tagger,"
          TT.opts: ",TT.opts,"
          TT.params: ",TT.params,"
          TT.filter.command: ",TT.filter.command,"\n
          sys.tt.call: ",sys.tt.call,"\n"))
      } else {
        message(paste("
          file: ",takeAsFile,"
          sys.tt.call: ",sys.tt.call,"\n"))
      }
    } else {}

    ## do the system call
    if(isTRUE(unix.OS)){
      tagged.text <- system(sys.tt.call, ignore.stderr=TRUE, intern=TRUE)
    } else {
      tagged.text <- shell(sys.tt.call, translate=FALSE, ignore.stderr=TRUE, intern=TRUE)
    }
    # TreeTagger should return UTF-8; explicitly declare it so there's no doubt about it
    Encoding(tagged.text) <- "UTF-8"

    ## workaround
    # in seldom cases TreeTagger seems to return duplicate tab stops
    # we'll try to correct for that here
    tagged.text <- gsub("\t\t", "\t", tagged.text)

    if(isTRUE(rm.sgml)){
      tagged.text <- tagged.text[grep("^[^<]", tagged.text)]
    } else {}

    ## try to catch error in local TreeTagger setup
    # when TreeTagger is not set up correctly, the system call will not fail loudly
    # but simply not return any useful data. this in turn will definitely cause
    # treetag() to fail with an error. we'll make it obvious that probably not
    # not koRpus is to blame for this -- but it could also be preset bugs!
    tagged.text <- unlist(strsplit(tagged.text, "\t"))
    if(is.null(tagged.text)){
      stop(simpleError(paste0(
        "Awww, this should not happen: TreeTagger didn't return any useful data.\n",
        "  This can happen if the local TreeTagger setup is incomplete or different from what presets expected.\n",
        "  You should re-run your command with the option 'debug=TRUE'. That will print all relevant configuration.\n",
        "  Look for a line starting with 'sys.tt.call:' and try to execute the full command following it in a\n",
        "  command line terminal. Do not close this R session in the meantime, as 'debug=TRUE' will keep temporary\n",
        "  files that might be needed.\n",
        "  If running the command after 'sys.tt.call:' does fail, you'll need to fix the TreeTagger setup.\n",
        "  If it does *not* fail but produce a table with proper results, please contact the author!"
      )))
    } else {
      tagged.mtrx <- matrix(tagged.text, ncol=3, byrow=TRUE, dimnames=list(c(),c("token","tag","lemma")))
    }

    # add sentence endings as defined
    if(isTRUE(apply.sentc.end)){
      sntc.end.tag <- kRp.POS.tags(lang, tags="sentc", list.tags=TRUE)[[1]]
      matched.sentc.tokens <- tagged.mtrx[, "token"] %in% sentc.end
      tagged.mtrx[matched.sentc.tokens, "tag"] <- sntc.end.tag
    } else {}
    ## for debugging:
    if(isTRUE(debug)){
      return(tagged.mtrx)
    } else {}

    # add word classes, comments and numer of letters ("wclass", "desc", "lttr")
    tagged.mtrx <- treetag.com(tagged.mtrx, lang=lang, add.desc=add.desc)

    # probably apply stopword detection and stemming
    tagged.mtrx <- stopAndStem(tagged.mtrx, stopwords=stopwords, stemmer=stemmer, lowercase=TRUE)

    # add columns "idx", "sntc" and "doc_id"
    tagged.mtrx <- indexSentenceDoc(tagged.mtrx, lang=lang, doc_id=doc_id)

    results <- kRp_text(lang=lang, tokens=tagged.mtrx)
    ## descriptive statistics
    if(is.null(encoding)){
      encoding <- ""
    } else {}
    txt.vector <- readLines(takeAsFile, encoding=encoding, warn=FALSE)
    # force text into UTF-8 format
    txt.vector <- enc2utf8(txt.vector)
    describe(results)[[doc_id]] <- basic.tagged.descriptives(results, lang=lang, txt.vector=txt.vector, doc_id=doc_id)

    return(results)
  }
)


#' @export
#' @docType methods
#' @rdname treetag-methods
#' @aliases treetag,kRp.connection-method
#' @include 01_class_81_kRp.connection_union.R
setMethod("treetag",
  signature(file="kRp.connection"),
  function(file, treetagger="kRp.env", rm.sgml=TRUE, lang="kRp.env",
    apply.sentc.end=TRUE, sentc.end=c(".","!","?",";",":"),
    encoding=NULL, TT.options=NULL, debug=FALSE, TT.tknz=TRUE,
    format=NA, stopwords=NULL, stemmer=NULL, doc_id=NA, add.desc="kRp.env"){

    takeAsFile <- dumpTextToTempfile(text=file, encoding=encoding)
    if(!isTRUE(debug)){
      on.exit(unlink(takeAsFile), add=TRUE)
    } else {}

    results <- treetag(file=takeAsFile, treetagger=treetagger, rm.sgml=rm.sgml, lang=lang,
      apply.sentc.end=apply.sentc.end, sentc.end=sentc.end,
      encoding=encoding, TT.options=TT.options, debug=debug, TT.tknz=TT.tknz,
      format="file", stopwords=stopwords, stemmer=stemmer, doc_id=doc_id, add.desc=add.desc
    )
    
    return(results)
  }
)
