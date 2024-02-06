#' get_persons
#' A function to return persons from BibEntry and bibentry objects
#' @docType function
#' @title get_persons - return person objects from BibEntry or bibentry object
#' @name get_persons
#' @param bib A BibEntry or bibentry object that may be subselected
#' from a larger set
#' @param refbib A BibEntry or bibentry object that contains any
#' crossreferences relevant to the function, such as exclude_crossref. Required
#' for excluding persons inherited from crossref entries.
#' @param exclude_crossref The InProceedings entries for this dataset reference
#' their respective Proceedings entries. RefManageR::ReadBib combines the parent
#' fields when the dataset is built. Setting exclude_crossref = TRUE prevents
#' the parent person fields from being duplicated for the InProceedings entries.
#' @return A data.frame with columns: family, given, role, key, and crossref
#' @export
#'
#' @examples
#' obj <- icusbib[author = "Silva", year = "1988"]
#' obj
#' get_persons(obj , data = icusbib, exclude_crossref = FALSE)
#' get_persons(obj , data = icusbib, exclude_crossref = TRUE)
#' obj <- icusbib[list(author = "Kubler"), list(author="^Oates")]
#' obj
#' get_persons(obj , data = icusbib, exclude_crossref = FALSE)
#' get_persons(obj , data = icusbib, exclude_crossref = TRUE)
#' @seealso
#' \link{icusbib}
get_persons <- function(bib, data = NULL, exclude_crossref = FALSE) {
  df <- data.frame(key = character(),
                   crossref = character(),
                   role = character(),
                   family = character(),
                   given = character(),
                   stringsAsFactors = FALSE)
  lenbib <- length(bib)
  for (i in 1:lenbib) {
    key <- bib[[i]]$key
    cref <- ifelse(is.null(bib[[i]]$crossref), "NA", bib[[i]]$crossref)
    persons <- unlist(bib[[i]], recursive = FALSE)
    isp <- sapply(persons, inherits, "person")
    roles <- persons[isp]
    lenroles <- length(roles)
    if (lenroles > 0) {
      df1 <- data.frame(role = character(),
                        family = character(),
                        given = character(),
                        stringsAsFactors = FALSE)
      rns <- names(roles)
      for (j in 1:lenroles) {
        lenflist <- length(roles[[j]])
        flist <- roles[[j]]$family
        for (k in 1:lenflist) {
          fam <- stringi::stri_paste(roles[[j]][k]$family, collapse = " ")
          glist <- stringi::stri_paste(roles[[j]][k]$given, collapse = " ")
          tryCatch({
            dfa <- list2DF(list(family = fam, given = glist))
          }
          , error = function(e) {
            print(key)
            print(i)
            print(j)
            print(k)
            print(flist)
            print(length(flist))
            print(glist)
            print(length(glist))
            print(stringi::stri_paste(roles[[j]]$given[k], collapse = " "))
            print(RefManageR::toBiblatex(bib[[i]]))
          })
          dfa$role <- rns[j]
          df1 <- rbind(df1, dfa)
        }
      }

      df1$key <- key
      df1$crossref <- cref
      df <- rbind(df, df1)
    }
  }
  if (exclude_crossref == TRUE && inherits(data, "bibentry")) {
    dfx <- data.frame(key = character(),
                      crossref = character(),
                      role = character(),
                      family = character(),
                      given = character(),
                      stringsAsFactors = FALSE)
    crs <- unique(unlist(bib$crossref)) # get keys of crossref fields in sample
    dfx <- get_persons(data[data$key %in% crs],
                       data = NULL, exclude_crossref = FALSE) # use defaults
    if (length(dfx) > 0) {
      df <- df[-which((df$role %in% dfx$role) &
                        (df$crossref %in% dfx$key) &
                        (df$family %in% dfx$family)), ]
    }
  }
  return(df)
}