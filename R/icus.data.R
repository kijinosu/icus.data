#' icus.data
#' A data package for icus.data.
#' @docType package
#' @aliases icus.data-package
#' @title Dataset for International Conferences on the Unity of Science
#' @name icus.data
#' @description More than 2000 scientists and scholars participated in the 22
#'     International Conferences on the Unity of the Sciences (ICUS)
#'     held between 1972 and 2000. The main spreadsheet in this dataset
#'     is a table of 2045 people who have been
#'     listed in ICUS programs as speakers, moderators, discussants,
#'     advisors and other committee members. This dataset contains
#'     tables related to researching these conferences.
#' @details Use \code{data(package='icus.data')$results[, 3]} to see
#' a list of available data sets in this data package.
#' @seealso
#' \link{nobels}
#' \link{participants}
#' \link{programs}
#' \link{role_defs}
#' \link{whoswho}
NULL



#' Detailed description of the data
#' @name nobels
#' @docType data
#' @title Nobel Laureates who participated in ICUS
#' @description In his 1977 criticism of ICUS IV, 
#' Irving Horowitz noted the prominence of Nobel
#' Laureates on the program and a striking fall-off 
#' in talent beyond a stellar list of
#' sponsors. This table is based on the Nobel Media AB
#' dataset.
#' @format a \code{data.table} containing the following fields:
#' \describe{
#' \item{ID}{ID for participants, relational to \code{participants} table}
#' \item{Surname}{}
#' \item{Given}{}
#' \item{Year}{Year in which participant receive Nobel Prize}
#' \item{Category}{Category of prize}
#' \item{OrgCountry}{Country of recipient's organization}
#' }
#' @source {The data comes fromNobel Media AB.}
#' @examples
#' library(icus.data)
#' nobels
#' @seealso
#' \link{icus.data}
#' \link{participants}
#' \link{programs}
#' \link{role_defs}
#' \link{whoswho}
NULL



#' Detailed description of the data
#' @name participants
#' @docType data
#' @title ICUS participants and their roles
#' @description Pariticpants in ICUS confereneces were manually compiled from
#' ICUS programs. See the vignette 
#' \code{icus.data::icus-program-observations}
#' for observations about the 22 conference programs. During compilation,
#' the various roles of the participants were entered for each conference.
#' The resulting Excel file is incuded in this package in folder \code{extdata}.
#' @format a \code{data.table} containing the following fields:
#' \describe{
#' \item{ID}{Format: ICUSxxxx. Assigned sequentially to rows in 
#' \code{ICUSRoles.xlsx}. 
#' This is the authoratitive relational column. Other tables are
#' copied from here.}
#' \item{Surname}{}
#' \item{Given}{}
#' \item{Conference}{Format: ICUSxx }
#' \item{Role}{Single character codes. Definitions in role_defs.}
#' }
#' @source The data comes from ICUS programs.
#' @details The original data is in wide format with ICUSxx as column 
#' headers and
#' the cells filled with character strings consisting of the roles the named
#' participant filled in the conference. Only one letter per type of role even
#' though a participant may have filled a role more that once in a
#' conference.
#' This is most common for discussant (X) roles. The original table can 
#' be viewed by running the examples. The \code{data.table} 
#' \code{participants} is in long
#' format with the role strings also pivoted.
#' @examples
#' ## Load and view original roles from \code{ICUSRoles.xlsx}
#' xlsx <- file.path(system.file(package="icus.data"),"extdata","ICUSRoles.xlsx")
#' library(readxl)
#' library(data.table)
#' excel_sheets(xlsx)
#' roles <- as.data.table(read_xlsx(xlsx, sheet="CrossChart"))
#' roles
#' ##
#' library(icus.data)
#' participants
#' @seealso
#' \link{icus.data}
#' \link{nobels}
#' \link{programs}
#' \link{role_defs}
#' \link{whoswho}
NULL



#' Detailed description of the data
#' @name programs
#' @docType data
#' @title Summary data from ICUS program brochures
#' @description Pariticpants in ICUS confereneces were manually compiled from
#' ICUS programs. See the vignette
#' \code{icus.data::ICUSPrograms}.
#' @format a \code{data.table} containing the following fields:
#' \describe{
#' \item{Conference}{}
#' \item{Year}{}
#' \item{Site}{Name of hotel}
#' \item{City}{}
#' \item{Country}{}
#' \item{ProgTitle}{}
#' \item{Participants*}{Number of participants per official ICUS website.}
#' \item{Nations}{Number of nations represented by participants per official ICUS website.}
#' \item{ProgPages}{Number of pages in program brochure}
#' \item{Cover}{Number of cover pages.}
#' \item{Title}{Number of title pages}
#' \item{Foreword}{}
#' \item{Purpose}{}
#' \item{Executive}{}
#' \item{TOC}{Table of contents pages}
#' \item{Structure}{Number of pages detailing structure of conferenc}
#' \item{Schedule}{Number of pages detailing speaking sessions and schedule}
#' \item{Participants}{Pages devoted to background info about participants}
#' \item{Sponsor}{Pages providing information about ICUS history and sponsors include book sales}
#' \item{Obituary}{Pages devoted to obituaries}
#' \item{Venue}{}
#' }
#' @source The data comes from ICUS program brochures on ICUS website (see vignette).
#' @details This \code{data.table} is the \code{Summary} sheet from
#' \code{ICUSPrograms.xlsx} in wide format. It is in part aggregated from
#' conference-specific sheets that are included with \code{ICUSPrograms.xlsx}
#' in \code{extdata}. See examples and vignette.
#' @examples
#' ## Load and view a conference sheet from \code{ICUSPrograms.xlsx}
#' library(readxl)
#' library(data.table)
#' xlsx <- file.path(system.file(package="icus.data"),"extdata","ICUSPrograms.xlsx")
#' ## view list of sheets
#' excel_sheets(xlsx)
#' ## load one conference sheet
#' confpages <- as.data.table(read_xlsx(xlsx, sheet="ICUS16"))
#' confpages
#' @seealso
#' \link{icus.data}
#' \link{nobels}
#' \link{participants}
#' \link{role_defs}
#' \link{whoswho}
NULL



#' Detailed description of the data
#' @name role_defs
#' @docType data
#' @title Definitions of role codes
#' @description Simple table of roles of participants in ICUS. ICUS
#' staff were excluded.
#' @format a \code{tbl_df} containing the following fields:
#' \describe{
#' \item{Abbr}{Single-character code}
#' \item{Role}{Definition of role}
#' }
#' @source The data is derived from ICUS programs.
#' @examples
#' library(icus.data)
#' role_defs
#' @details Table \code{role_defs} is from sheet \code{Legend}
#' of \code{ICUSRoles.xlsx}.
#' @seealso
#' \link{nobels}
#' \link{icus.data}
#' \link{participants}
#' \link{programs}
#' \link{whoswho}
NULL



#' Detailed description of the data
#' @name whoswho
#' @docType data
#' @title ICUS participants listed in International Who's Who
#' @description Results of manual searches on participants in Marquis
#' International Who's Who. The participants' birthdates were
#' recorded both for quality control checks and to be able to
#' determine age at participation in ICUS.
#' @format A \code{data.table} containing the following fields:
#' \describe{
#' \item{ID}{Format: ICUSxxxx. Assigned sequentially to rows in ICUSRoles.xlsx. 
#' Those are the authoritative assignments.
#' copied from there.}
#' \item{Surname}{}
#' \item{Given}{}
#' \item{Edition}{Edition of Who's Who.}
#' \item{Birthdate}{Birthdate of participant.}
#' }
#' @source Manual searches of International Who's Who, Editions 40, 50 and 60.
#' @details Folder \code{extdata} contains csv and tsv versions of this table
#' in wide format with the Edition numbers as column heads. Participants not
#' listed in the Who's Who are includeed with <NA> entries.
#' @examples
#' csv <- file.path(system.file(package="icus.data"),"extdata","whoswho.csv")
#' whoswho.wide <- read.csv(csv)
#' whoswho.wide[1:20,]
#' ## See whoswho in long format.
#' library(icus.data)
#' whoswho
#' @seealso
#' \link{nobels}
#' \link{icus.data}
#' \link{participants}
#' \link{programs}
#' \link{role_defs}
NULL



