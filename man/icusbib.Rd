% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/icus.data.R
\docType{data}
\name{icusbib}
\alias{icusbib}
\title{Bibliographic dataset for ICUS programs}
\format{
A \code{BibEntry}
}
\source{
Manually compiled from ICUS program brochures.
}
\description{
BibLatex records based on program brochures
for ICUS I through ICUS XXII packaged as a BibEntry using
RefManageR.
}
\details{
Detailed description of the data

Folder \code{extdata/icusbib-raw} contains one BibLatex
file for each of the 22 ICUS conferences that are
read to produce dataset \code{icusbib}. The BibLatex entries
use the \code{@proceedings} and \code{@inproceedings} entry types.
The BibLatex input files also make extend use of keys and
\code{@Set} entries to capture hierarchies in the programs.
Please see the \link{icus.data::icus-program-observations}
vignette for details about the hierarchies. A example of
a \code{@Set} follows:
\preformatted{@Set{ICUS02:C01:G01,
  entryset = {ICUS02:C01:G01:S01},
  pattern = {ICUS02:C01:G01:[S|X]},
  patterntype = {key},
  settype = {Committee},
  title = {Committee session I},
  level = {3},
  editorctype={organizer},
  editorc = {Hintikka, Kaarlo Jaakko Juhani and Yoshida, Natsuhiko},}
}
This entry adds a \code{pattern} field containing a regular
expression that selects the entries below. RefManageR will not
read a \code{@Set} that has an empty \code{entryset} so this
is seeded with the first member of the entryset. When reading
the BibLatex files, the build function uses the pattern to
compute the full entryset. The patterntype field anticipates
other kinds of methods for creating \code{@Set}s but only
the \code{key} method is implemented in this version.
}
\examples{
library(icus.data)
icusbib[1:5]
## count number of InProceedings entries in icusbib
length(icusbib[bibtype = "InProceedings"])
## Search for presentations by Delgado.
icusbib[author = "Delgado"]
## Use draft style.
print(SearchBib(icusbib, author="Delgado"),
                .opts = list(bib.style = "draft"))
## Search for commentary by Delgado.
icusbib[commentator = "Delgado"]
## Look at extended Set entry
toBiblatex(icusbib[entryset = "ICUS06:C04:G02"])
}
\seealso{
\link{icus.data}
\link{get_persons}
\link{nobels}
\link{participants}
\link{programs}
\link{role_defs}
\link{viaf}
\link{whoswho}
}
