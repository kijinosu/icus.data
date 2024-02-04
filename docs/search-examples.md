-   [Searching the `icusbib` dataset](#searching-the-icusbib-dataset)
-   [The underlying RefManageR
    package](#the-underlying-refmanager-package)
-   [Structure and output styles](#structure-and-output-styles)
-   [Bibliographic styles](#bibliographic-styles)
-   [Search](#search)
-   [References](#references)

# Searching the `icusbib` dataset

`icusbib` is a list of `RefManageR::BibEntry` objects that covers all
presentations, including commentary, in the first 22 ICUS conferences as
provided on the ICUS website ([*International Conference on the Unity of
the Sciences - History* 2020](#ref-icushistory)).

This vignette will illustrate various searches.

# The underlying RefManageR package

This package is built on Mathew McLean’s `RefManageR` package([McLean
2014](#ref-refmanager)), which in turn builds on ([Patashnik
1988](#ref-bibtex)) and ([Lehman et al. 2022](#ref-biblatex)). Mathew
McLean’s excellent user manual for RefManageR is
[here](https://cran.r-project.org/web/packages/RefManageR/vignettes/manual.pdf).
There is also an online [reference
manual](https://cloud.r-project.org/web/packages/RefManageR/RefManageR.pdf).
In presenting the examples below, I will try to remain consistent with
these references.

Begin by loading the R library. This also loads RefManageR.

    library(icus.data)

# Structure and output styles

Let’s take a look at the first entry in `icusbib`.

    icusbib[1]

    ## [1] _Moral Orientation of the Sciences_. First International Conference
    ## on Unified Science. (Waldorf-Astoria Hotel, 11. 23, 1972-11. 26, 1972)
    ## chairpersonE. Laszlo and E. Haskell. Council for Unified Research and
    ## Education. New York, New York, 1972.
    ## <https://icus.org/wp-content/uploads/2016/03/1st-ICUS-New-York-City-1972.pdf>
    ## (visited on 05/01/2023).

RefManageR’s default output style is “numeric”.

    BibOptions("bib.style")

    ## $bib.style
    ## [1] "numeric"

## Biblatex Proceedings entries

To see Biblatex entries in full, we use the `toBiblatex()` function.

    toBiblatex(icusbib[1])

    ## @Proceedings{ICUS01,
    ##   title = {Moral Orientation of the Sciences},
    ##   titleaddon = {First International Conference on Unified Science},
    ##   editora = {Ervin Laszlo and E.F. Haskell},
    ##   editoratype = {chairperson},
    ##   shorttitle = {ICUS I},
    ##   eventdate = {1972-11-23/1972-11-26},
    ##   venue = {Waldorf-Astoria Hotel},
    ##   organization = {Council for Unified Research and Education},
    ##   location = {New York, New York},
    ##   date = {1972},
    ##   url = {https://icus.org/wp-content/uploads/2016/03/1st-ICUS-New-York-City-1972.pdf},
    ##   urldate = {2023-05-01},
    ##   keywords = {primary, program, moonist},
    ## }

The original bibliographic file `ICUS01.bib` contained the following.

    @Proceedings{ICUS01,
      title = {Moral Orientation of the Sciences},
      titleaddon = {First International Conference on Unified Science},
      editora = {Ervin Laszlo and E.F. Haskell},
      editoratype = {organizer},
      shorttitle = {ICUS I},
      eventdate = {1972-11-23/1972-11-26},
      venue = {Waldorf-Astoria Hotel},
      organization = {Council for Unified Research and Education},
      location = {New York, New York},
      date = {1972},
      url = {https://icus.org/wp-content/uploads/2016/03/1st-ICUS-New-York-City-1972.pdf},
      urldate = {2023-05-01},
      keywords = {primary, program, moonist},
    }

**icusbib** uses the three entry types `@Proceedings`, `@InProceedings`
and `@Set`. **icus.date** uses the **key** field to capture the
hierarchy, tracks and sessions of ICUS conferences. For details, please
see [ICUS Programs: Observations and
Coding](https://osf.io/c2nd6%20%22ICUS%20Programs:%20Observations%20and%20Coding%22)
([Engel 2024](#ref-engel2024moonism)). In this record, ‘ICUS01’ is the
key for the main entry for ICUS I.

## InProceedings entries

The first entry in **icusbib** is a `@Proceedings` entry. Now take a
look at an `@InProceedings` entry from the same conference. This is the
entry in the manually prepared bibliographic files. You can view this
file [here](https://osf.io/ksr2q).

    @InProceedings{ICUS01:C01:G01:S01,
    crossref={ICUS01},
    author={Camilo Dagum},
    title={The Impact of Unified Science on Economics}
    }

`toBiblatex()` outputs the following. This shows that RefManageR folds
the content of `icusbib[1]` into this entry based on the value of
`crossref`. This operation occurs when the file is read when building
the data package and is **NOT** dynamic. In other words, changes to the
`@Proceedings` entry in `icusbib[1]` will not propagate to its
downstream `crossref` entries.

Searches are on these combined entries. It should be evident that
changing keys will corrupt the dataset.

    toBiblatex(icusbib[4])

    ## @InProceedings{ICUS01:C01:G01:S01,
    ##   crossref = {ICUS01},
    ##   author = {Camilo Dagum},
    ##   title = {The Impact of Unified Science on Economics},
    ##   editora = {Ervin Laszlo and E.F. Haskell},
    ##   editoratype = {chairperson},
    ##   shorttitle = {ICUS I},
    ##   eventdate = {1972-11-23/1972-11-26},
    ##   venue = {Waldorf-Astoria Hotel},
    ##   organization = {Council for Unified Research and Education},
    ##   location = {New York, New York},
    ##   date = {1972},
    ##   url = {https://icus.org/wp-content/uploads/2016/03/1st-ICUS-New-York-City-1972.pdf},
    ##   urldate = {2023-05-01},
    ##   keywords = {primary, program, moonist},
    ##   booktitle = {Moral Orientation of the Sciences},
    ##   booktitleaddon = {First International Conference on Unified Science},
    ## }

## Set entries: unorthodox usage in order to capture hierarchies and groups

ICUS conferences were multitracked with various interest areas and
groups. Biblatex’s ([Lehman et al. 2022](#ref-biblatex)) **crossref**
field only provides for one parent, and in this application that is the
**Proceedings** entry for each conference. In order to capture the
intermediate levels and ferret out various interest groups, I extended
the Set entry at two levels.

There is redundancy in this workaround so bear with me.

The first extension is an added **pattern** field, which is a regular
expression that enables the **entryset** value to be computed when the
dataset is built. one redundancy here is that the **key** values in this
application reflect the hierarchy and are sufficient. A **pattertype**
field allows for other yet to be implemented schemes for determining the
entry set.

A **level** field specifies the level in the hierarchy and will be used
for ‘’birds-of-a-feather’’ searches. **setype** specifies the kind of
set and the **title** field accommodates a specific title if there was
one in the program brochure.

The **editorc** is for chairpersons or moderators. It is a **person**
object that is searchable using RefManageR’s `SearchBib()` function and
`+.BibEntry operator`.

Currently, the available styles only output the **Set** bibtype and
**key**. There is also no built-in referencing so this must be added
ad-hoc.

    s <- icusbib[bibtype = "Set", key = "ICUS03"][1:2]
    s

    ## Set: ICUS03:C01
    ## 
    ## Set: ICUS03:C01:G01

    toBiblatex(s)

    ## @Set{ICUS03:C01,
    ##   entryset = {ICUS03:C01:G01:S01},
    ##   pattern = {ICUS03:C01:G\d\d:[S|X]},
    ##   patterntype = {key},
    ##   level = {2},
    ##   settype = {Committee},
    ##   title = {Quality of life: physical, mental and spiritual aspects},
    ## }
    ## 
    ## @Set{ICUS03:C01:G01,
    ##   entryset = {ICUS03:C01:G01:S01},
    ##   pattern = {ICUS03:C01:G01:[S|X]},
    ##   patterntype = {key},
    ##   settype = {Session},
    ##   title = {Session 1},
    ##   level = {3},
    ##   editorctype = {organizer},
    ##   editorc = {S. L. Cook},
    ## }

# Bibliographic styles

Possible values for `bib.style` are “numeric” (default), “authoryear”,
“authortitle”, “alphabetic”, “draft”. (See [RefManageR on
CRAN](https://cran.r-project.org/web/packages/RefManageR/RefManageR.pdf)
for details.) These styles are illustrated below.

## Numeric (default)

    icusbib[4]

    ## [1] C. Dagum. "The Impact of Unified Science on Economics". In: _Moral
    ## Orientation of the Sciences_. First International Conference on Unified
    ## Science. (Waldorf-Astoria Hotel, 11. 23, 1972-11. 26, 1972).
    ## chairpersonE. Laszlo and E. Haskell. Council for Unified Research and
    ## Education. New York, New York, 1972.
    ## <https://icus.org/wp-content/uploads/2016/03/1st-ICUS-New-York-City-1972.pdf>
    ## (visited on 05/01/2023).

## authoryear

    oldstyle <- BibOptions(bib.style = "authoryear")
    icusbib[4]

    ## Dagum, C. (1972). "The Impact of Unified Science on Economics". In:
    ## _Moral Orientation of the Sciences_. First International Conference on
    ## Unified Science. (Waldorf-Astoria Hotel, 11. 23, 1972-11. 26, 1972).
    ## chairpersonE. Laszlo and E. Haskell. Council for Unified Research and
    ## Education. New York, New York.
    ## <https://icus.org/wp-content/uploads/2016/03/1st-ICUS-New-York-City-1972.pdf>
    ## (visited on 5. 01, 2023).

## authortitle

    BibOptions(bib.style = "authortitle")
    icusbib[4]

    ## Dagum, C. "The Impact of Unified Science on Economics". In: _Moral
    ## Orientation of the Sciences_. First International Conference on Unified
    ## Science. (Waldorf-Astoria Hotel, 11. 23, 1972-11. 26, 1972).
    ## chairpersonE. Laszlo and E. Haskell. Council for Unified Research and
    ## Education. New York, New York, 1972.
    ## <https://icus.org/wp-content/uploads/2016/03/1st-ICUS-New-York-City-1972.pdf>
    ## (visited on 05/01/2023).

## alphabetic

    BibOptions(bib.style = "alphabetic")
    icusbib[4]

    ## [Dag72] C. Dagum. "The Impact of Unified Science on Economics". In:
    ## _Moral Orientation of the Sciences_. First International Conference on
    ## Unified Science. (Waldorf-Astoria Hotel, 11. 23, 1972-11. 26, 1972).
    ## chairpersonE. Laszlo and E. Haskell. Council for Unified Research and
    ## Education. New York, New York, 1972.
    ## <https://icus.org/wp-content/uploads/2016/03/1st-ICUS-New-York-City-1972.pdf>
    ## (visited on 05/01/2023).

## draft

    BibOptions(bib.style = "draft")
    icusbib[4]

    ## *ICUS01:C01:G01:S01* C. Dagum. "The Impact of Unified Science on
    ## Economics". In: _Moral Orientation of the Sciences_. First
    ## International Conference on Unified Science. (Waldorf-Astoria Hotel,
    ## 11. 23, 1972-11. 26, 1972). chairpersonE. Laszlo and E. Haskell.
    ## Council for Unified Research and Education. New York, New York, 1972.
    ## <https://icus.org/wp-content/uploads/2016/03/1st-ICUS-New-York-City-1972.pdf>
    ## (visited on 05/01/2023).

    BibOptions(oldstyle)

## Using print()

The bibliographic style can also be selected in `print` so that you do
not to change the global option just for one output.

    print(icusbib[4], .opts = list(bib.style = "draft"))

    ## *ICUS01:C01:G01:S01* C. Dagum. "The Impact of Unified Science on
    ## Economics". In: _Moral Orientation of the Sciences_. First
    ## International Conference on Unified Science. (Waldorf-Astoria Hotel,
    ## 11. 23, 1972-11. 26, 1972). chairpersonE. Laszlo and E. Haskell.
    ## Council for Unified Research and Education. New York, New York, 1972.
    ## <https://icus.org/wp-content/uploads/2016/03/1st-ICUS-New-York-City-1972.pdf>
    ## (visited on 05/01/2023).

Now let’s take a look at the structure of this BibEntry below. Because
this is an `InProceedings` entry with a `crossref` to a corresponding
`Proceedings` entry, this BibEntry is a combination of the two. Note
that the `title` and `titleaddon` fields from the `Proceedings` entry
have been assigned to `booktitle` and `booktitleaddon` fields to avoid
conflict.

    str(icusbib[4])

    ## Classes 'BibEntry', 'bibentry'  hidden list of 1
    ##  $ :List of 16
    ##   ..$ crossref      : chr "ICUS01"
    ##   ..$ author        :Class 'person'  hidden list of 1
    ##   .. ..$ :List of 5
    ##   .. .. ..$ given  : chr "Camilo"
    ##   .. .. ..$ family : chr "Dagum"
    ##   .. .. ..$ role   : NULL
    ##   .. .. ..$ email  : NULL
    ##   .. .. ..$ comment: NULL
    ##   ..$ title         : chr "The Impact of Unified Science on Economics"
    ##   ..$ editora       :List of 2
    ##   .. ..$ :Class 'person'  hidden list of 1
    ##   .. .. ..$ :List of 5
    ##   .. .. .. ..$ given  : chr "Ervin"
    ##   .. .. .. ..$ family : chr "Laszlo"
    ##   .. .. .. ..$ role   : NULL
    ##   .. .. .. ..$ email  : NULL
    ##   .. .. .. ..$ comment: NULL
    ##   .. ..$ :Class 'person'  hidden list of 1
    ##   .. .. ..$ :List of 5
    ##   .. .. .. ..$ given  : chr "E.F."
    ##   .. .. .. ..$ family : chr "Haskell"
    ##   .. .. .. ..$ role   : NULL
    ##   .. .. .. ..$ email  : NULL
    ##   .. .. .. ..$ comment: NULL
    ##   .. ..- attr(*, "class")= chr "person"
    ##   ..$ editoratype   : chr "chairperson"
    ##   ..$ shorttitle    : chr "ICUS I"
    ##   ..$ eventdate     : chr "1972-11-23/1972-11-26"
    ##   ..$ venue         : chr "Waldorf-Astoria Hotel"
    ##   ..$ organization  : chr "Council for Unified Research and Education"
    ##   ..$ location      : chr "New York, New York"
    ##   ..$ date          : chr "1972"
    ##   ..$ url           : chr "https://icus.org/wp-content/uploads/2016/03/1st-ICUS-New-York-City-1972.pdf"
    ##   ..$ urldate       : chr "2023-05-01"
    ##   ..$ keywords      : chr "primary, program, moonist"
    ##   ..$ booktitle     : chr "Moral Orientation of the Sciences"
    ##   ..$ booktitleaddon: chr "First International Conference on Unified Science"
    ##   ..- attr(*, "bibtype")= chr "InProceedings"
    ##   ..- attr(*, "key")= chr "ICUS01:C01:G01:S01"
    ##   ..- attr(*, "dateobj")= POSIXct[1:1], format: "1972-01-01"

# Search

## Searchable fields

Most of the 14 fields and 3 attributes in this structure can be
searched. Here I search the title with two equivalent syntaxes.

    icusbib[title = "Economics"][key = "ICUS01"]

    ## [1] C. Dagum. "The Impact of Unified Science on Economics". In: _Moral
    ## Orientation of the Sciences_. First International Conference on Unified
    ## Science. (Waldorf-Astoria Hotel, 11. 23, 1972-11. 26, 1972).
    ## chairpersonE. Laszlo and E. Haskell. Council for Unified Research and
    ## Education. New York, New York, 1972.
    ## <https://icus.org/wp-content/uploads/2016/03/1st-ICUS-New-York-City-1972.pdf>
    ## (visited on 05/01/2023).

    icusbib[title = "Economics", key = "ICUS01"]

    ## [1] C. Dagum. "The Impact of Unified Science on Economics". In: _Moral
    ## Orientation of the Sciences_. First International Conference on Unified
    ## Science. (Waldorf-Astoria Hotel, 11. 23, 1972-11. 26, 1972).
    ## chairpersonE. Laszlo and E. Haskell. Council for Unified Research and
    ## Education. New York, New York, 1972.
    ## <https://icus.org/wp-content/uploads/2016/03/1st-ICUS-New-York-City-1972.pdf>
    ## (visited on 05/01/2023).

This is a Boolean AND search that can be read as (title = “Economics”
AND key = “ICUS01”). The top syntax says, “Search on the title, then
search those results on the key.” The bottom syntax is from [McLean’s
user
manual](https://cran.r-project.org/web/packages/RefManageR/vignettes/manual.pdf).

Of the fields imported from the `Proceedings` entry, `booktitle`
**cannot** be searched but `venue` can. (In the `venue` search below, I
have listed the first 2 entries.)

    icusbib[booktitle = "International"] # from Proceedings entry

    ## No results.

    ## list()

    icusbib[venue = "Waldorf"][1:2] # also from Proceedings entry

    ## [1] _Moral Orientation of the Sciences_. First International Conference
    ## on Unified Science. (Waldorf-Astoria Hotel, 11. 23, 1972-11. 26, 1972)
    ## chairpersonE. Laszlo and E. Haskell. Council for Unified Research and
    ## Education. New York, New York, 1972.
    ## <https://icus.org/wp-content/uploads/2016/03/1st-ICUS-New-York-City-1972.pdf>
    ## (visited on 05/01/2023).
    ## 
    ## [2] C. Dagum. "The Impact of Unified Science on Economics". In: _Moral
    ## Orientation of the Sciences_. First International Conference on Unified
    ## Science. (Waldorf-Astoria Hotel, 11. 23, 1972-11. 26, 1972).
    ## chairpersonE. Laszlo and E. Haskell. Council for Unified Research and
    ## Education. New York, New York, 1972.
    ## <https://icus.org/wp-content/uploads/2016/03/1st-ICUS-New-York-City-1972.pdf>
    ## (visited on 05/01/2023).

The BibEntry structure has authors, commentators and other persons in
`util::person` objects ([Bengtsson 2023](#ref-R-utils)) that are legacy
of the original bibtex ([Patashnik 1988](#ref-bibtex)) that is included
in CRAN’s core R installation ([R Core Team 2023](#ref-R-core)).

## Searching persons

### Default is regular expression search on family name

In searching `person` objects, the default option is to search the
`family` name only. Searching is for matching character strings and not
whole names.

    icusbib[author = "Joyce"] # given name

    ## No results.

    ## list()

    icusbib[author = "Oates"][1] # matching string in family name

    ## [1] V. T. Coates. "Technology Assessment and Public Policy". In:
    ## _Modern Science and Moral Values_. Second International Conference on
    ## the Unity of the Sciences. (Imperial Hotel, 11. 18, 1973-11. 21, 1973).
    ## chairpersonN. Sawada and N. Yosida. International Cultural Foundation.
    ## Tokyo, Japan, 1973.
    ## <https://icus.org/wp-content/uploads/2015/10/ICUSII-Program.pdf>
    ## (visited on 05/08/2023).

    icusbib[author = "^Oates"][1] # At the beginning of family name

    ## [1] J. C. Oates. "The art of suicide". In: _The re-evaluation of
    ## existing values and the search for absolute values_. The Seventh
    ## International Conference on the Unity of the Sciences. (Sheraton-Boston
    ## Hotel, 11. 24, 1978-11. 26, 1978). chairpersonE. P. Wigner and J. C.
    ## Eccles. With a comment. by I. Soll. International Cultural Foundation.
    ## Boston, MA, 1978.
    ## <https://icus.org/wp-content/uploads/2016/02/ICUS-VII-Program.pdf>
    ## (visited on 05/12/2023).

Different options enable different search results. Here I also show
examples using the `SearchBib` function, which allows the options to be
set locally for that query.

### Search on ‘exact’ and ‘family.with.initials’

    icusbib[author = "Dagum, Camilo"][1] # default option is "family"

    ## [1] C. Dagum. "The Impact of Unified Science on Economics". In: _Moral
    ## Orientation of the Sciences_. First International Conference on Unified
    ## Science. (Waldorf-Astoria Hotel, 11. 23, 1972-11. 26, 1972).
    ## chairpersonE. Laszlo and E. Haskell. Council for Unified Research and
    ## Education. New York, New York, 1972.
    ## <https://icus.org/wp-content/uploads/2016/03/1st-ICUS-New-York-City-1972.pdf>
    ## (visited on 05/01/2023).

    oldopts <- BibOptions(match.author = "exact")
    icusbib[author = "Dagum, Camilo"][1]

    ## [1] C. Dagum. "The Impact of Unified Science on Economics". In: _Moral
    ## Orientation of the Sciences_. First International Conference on Unified
    ## Science. (Waldorf-Astoria Hotel, 11. 23, 1972-11. 26, 1972).
    ## chairpersonE. Laszlo and E. Haskell. Council for Unified Research and
    ## Education. New York, New York, 1972.
    ## <https://icus.org/wp-content/uploads/2016/03/1st-ICUS-New-York-City-1972.pdf>
    ## (visited on 05/01/2023).

    BibOptions(oldopts)

    icusbib[author = "Dagum, Terry"][1] # default option is "family"

    ## [1] C. Dagum. "The Impact of Unified Science on Economics". In: _Moral
    ## Orientation of the Sciences_. First International Conference on Unified
    ## Science. (Waldorf-Astoria Hotel, 11. 23, 1972-11. 26, 1972).
    ## chairpersonE. Laszlo and E. Haskell. Council for Unified Research and
    ## Education. New York, New York, 1972.
    ## <https://icus.org/wp-content/uploads/2016/03/1st-ICUS-New-York-City-1972.pdf>
    ## (visited on 05/01/2023).

    oldopts <- BibOptions(match.author = "exact")
    icusbib[author = "Dagum, Terry"][1]

    ## No results.

    ## [[1]]
    ## NULL

    BibOptions(oldopts)

    SearchBib(icusbib, author = "Dagum", .opts = list(match.author = "family"))[1]

    ## [1] C. Dagum. "The Impact of Unified Science on Economics". In: _Moral
    ## Orientation of the Sciences_. First International Conference on Unified
    ## Science. (Waldorf-Astoria Hotel, 11. 23, 1972-11. 26, 1972).
    ## chairpersonE. Laszlo and E. Haskell. Council for Unified Research and
    ## Education. New York, New York, 1972.
    ## <https://icus.org/wp-content/uploads/2016/03/1st-ICUS-New-York-City-1972.pdf>
    ## (visited on 05/01/2023).

    SearchBib(icusbib, author = "Camilo", .opts = list(match.author = "given"))[1]

    ## No results.

    ## [[1]]
    ## NULL

    SearchBib(icusbib, author = "Dagum, C.",
      .opts = list(match.author = "family.with.initials"))[1]

    ## [1] C. Dagum. "The Impact of Unified Science on Economics". In: _Moral
    ## Orientation of the Sciences_. First International Conference on Unified
    ## Science. (Waldorf-Astoria Hotel, 11. 23, 1972-11. 26, 1972).
    ## chairpersonE. Laszlo and E. Haskell. Council for Unified Research and
    ## Education. New York, New York, 1972.
    ## <https://icus.org/wp-content/uploads/2016/03/1st-ICUS-New-York-City-1972.pdf>
    ## (visited on 05/01/2023).

    SearchBib(icusbib, author = "Dagum, Camilo",
      .opts = list(match.author = "family.with.initials"))[1]

    ## [1] C. Dagum. "The Impact of Unified Science on Economics". In: _Moral
    ## Orientation of the Sciences_. First International Conference on Unified
    ## Science. (Waldorf-Astoria Hotel, 11. 23, 1972-11. 26, 1972).
    ## chairpersonE. Laszlo and E. Haskell. Council for Unified Research and
    ## Education. New York, New York, 1972.
    ## <https://icus.org/wp-content/uploads/2016/03/1st-ICUS-New-York-City-1972.pdf>
    ## (visited on 05/01/2023).

    SearchBib(icusbib, author = "Dagum, Camilo",
      .opts = list(match.author = "exact"))[1]

    ## [1] C. Dagum. "The Impact of Unified Science on Economics". In: _Moral
    ## Orientation of the Sciences_. First International Conference on Unified
    ## Science. (Waldorf-Astoria Hotel, 11. 23, 1972-11. 26, 1972).
    ## chairpersonE. Laszlo and E. Haskell. Council for Unified Research and
    ## Education. New York, New York, 1972.
    ## <https://icus.org/wp-content/uploads/2016/03/1st-ICUS-New-York-City-1972.pdf>
    ## (visited on 05/01/2023).

    icusbib[author = "Dagum, Camilo", .opts = list(match.author = "exact")][1]

    ## No results.

    ## [[1]]
    ## NULL

## Dates

The default for searching dates is to search only by year
(‘’year.only’‘). Searching more precisely requires changing the
`match.date` option to’‘exact’’. Date ranges are specified with a
forward slash. The exclamation point is the NOT operator.

    icusbib[author = "delgado", date = "1979"]

    ## [1] J. M. R. Delgado. "Transmaterial values within the brain". In: _The
    ## responsibility of the academic community in the search for absolute
    ## values_. The Eighth International Conference on the Unity of the
    ## Sciences. (Century Plaza Hotel, 11. 22, 1979-11. 25, 1979).
    ## chairpersonE. P. Wigner and J. C. Eccles. With a comment. by S. L.
    ## Palay. International Cultural Foundation. Los Angeles, CA, 1979.
    ## <https://icus.org/wp-content/uploads/2016/02/ICUS-VIII-Program.pdf>
    ## (visited on 05/12/2023).

    icusbib[author = "delgado", date = "1979/1984"]

    ## [1] J. M. R. Delgado. "Biological bases on reality and imaginary". In:
    ## _Absolute Values and the New Cultural Revolution_. Thirteenth
    ## International Conference on the Unity of the Sciences. (J.W. Marriott
    ## Hotel, 9. 02, 1984-9. 05, 1984). chairpersonK. Mellanby, A. King and C.
    ## A. Villee Jr.. International Cultural Foundation. Washington, DC, USA,
    ## 1984.
    ## <https://icus.org/wp-content/uploads/2016/03/ICUS-XVIII-Program.pdf>
    ## (visited on 05/12/2023).
    ## 
    ## [2] J. M. R. Delgado. "Transmaterial values within the brain". In: _The
    ## responsibility of the academic community in the search for absolute
    ## values_. The Eighth International Conference on the Unity of the
    ## Sciences. (Century Plaza Hotel, 11. 22, 1979-11. 25, 1979).
    ## chairpersonE. P. Wigner and J. C. Eccles. With a comment. by S. L.
    ## Palay. International Cultural Foundation. Los Angeles, CA, 1979.
    ## <https://icus.org/wp-content/uploads/2016/02/ICUS-VIII-Program.pdf>
    ## (visited on 05/12/2023).

    icusbib[author = "delgado", date = "!1979/1984"] # not in this range

    ## [1] J. M. R. Delgado. "Forms, symbols and the structure of the brain".
    ## In: _Absolute Values and the New Cultural Revolution_. Fourteenth
    ## International Conference on the Unity of the Sciences. (Hotel
    ## Intercontinental, 11. 28, 1985-12. 01, 1985). chairpersonK. Mellanby,
    ## T. R. Gerholm and A. King. International Cultural Foundation. Houston,
    ## TX, USA, 1985.
    ## <https://icus.org/wp-content/uploads/2016/02/ICUS-XIV-Program.pdf>
    ## (visited on 05/12/2023).
    ## 
    ## [2] J. M. R. Delgado. "Neurobiological factors in the development of
    ## personhood". In: _Absolute Values and the Reassessment of the
    ## Contemporary World_. Sixteenth International Conference on the Unity of
    ## the Sciences. (Stouffer Waverly Hotel, 11. 26, 1987-11. 29, 1987).
    ## chairpersonA. M. Weinberg, T. R. Gerholm and N. Fukuda. With a comment.
    ## by L. Rakic. International Cultural Foundation. Washington, DC, USA,
    ## 1987.
    ## <https://icus.org/wp-content/uploads/2016/02/ICUS-XVI-Program.pdf>
    ## (visited on 05/12/2023).
    ## 
    ## [3] J. M. R. Delgado. "Neurobiology of global ideology and values". In:
    ## _Absolute Values and the Reassessment of the Contemporary World_.
    ## Seventeenth International Conference on the Unity of the Sciences.
    ## (Stouffer Concourse Hotel, 11. 24, 1988-11. 27, 1988). chairpersonA. M.
    ## Weinberg, M. Higatsberger and V. Cappelletti. International Cultural
    ## Foundation. Los Angeles, CA, USA, 1988.
    ## <https://icus.org/wp-content/uploads/2016/03/ICUS-XVII-Program.pdf>
    ## (visited on 05/12/2023).
    ## 
    ## [4] J. M. R. Delgado. "Psychobiology of space and time". In: _Absolute
    ## Values and the New Cultural Revolution_. Fifteenth International
    ## Conference on the Unity of the Sciences. (J.W. Marriott Hotel, 11. 27,
    ## 1986-11. 30, 1986). chairpersonK. Mellanby, A. M. Weinberg and A. King.
    ## International Cultural Foundation. Washington, DC, USA, 1986.
    ## <https://icus.org/wp-content/uploads/2016/02/ICUS-XV-Program.pdf>
    ## (visited on 05/12/2023).
    ## 
    ## [5] R. Rodriguez-Delgado. "New systems of values and ideologies: a
    ## general systems approach to find a framework for the future". In:
    ## _Absolute Values and the Reassessment of the Contemporary World_.
    ## Seventeenth International Conference on the Unity of the Sciences.
    ## (Stouffer Concourse Hotel, 11. 24, 1988-11. 27, 1988). chairpersonA. M.
    ## Weinberg, M. Higatsberger and V. Cappelletti. International Cultural
    ## Foundation. Los Angeles, CA, USA, 1988.
    ## <https://icus.org/wp-content/uploads/2016/03/ICUS-XVII-Program.pdf>
    ## (visited on 05/12/2023).

    icusbib[author = "delgado", date = "1987/"]

    ## [1] J. M. R. Delgado. "Neurobiological factors in the development of
    ## personhood". In: _Absolute Values and the Reassessment of the
    ## Contemporary World_. Sixteenth International Conference on the Unity of
    ## the Sciences. (Stouffer Waverly Hotel, 11. 26, 1987-11. 29, 1987).
    ## chairpersonA. M. Weinberg, T. R. Gerholm and N. Fukuda. With a comment.
    ## by L. Rakic. International Cultural Foundation. Washington, DC, USA,
    ## 1987.
    ## <https://icus.org/wp-content/uploads/2016/02/ICUS-XVI-Program.pdf>
    ## (visited on 05/12/2023).
    ## 
    ## [2] J. M. R. Delgado. "Neurobiology of global ideology and values". In:
    ## _Absolute Values and the Reassessment of the Contemporary World_.
    ## Seventeenth International Conference on the Unity of the Sciences.
    ## (Stouffer Concourse Hotel, 11. 24, 1988-11. 27, 1988). chairpersonA. M.
    ## Weinberg, M. Higatsberger and V. Cappelletti. International Cultural
    ## Foundation. Los Angeles, CA, USA, 1988.
    ## <https://icus.org/wp-content/uploads/2016/03/ICUS-XVII-Program.pdf>
    ## (visited on 05/12/2023).
    ## 
    ## [3] R. Rodriguez-Delgado. "New systems of values and ideologies: a
    ## general systems approach to find a framework for the future". In:
    ## _Absolute Values and the Reassessment of the Contemporary World_.
    ## Seventeenth International Conference on the Unity of the Sciences.
    ## (Stouffer Concourse Hotel, 11. 24, 1988-11. 27, 1988). chairpersonA. M.
    ## Weinberg, M. Higatsberger and V. Cappelletti. International Cultural
    ## Foundation. Los Angeles, CA, USA, 1988.
    ## <https://icus.org/wp-content/uploads/2016/03/ICUS-XVII-Program.pdf>
    ## (visited on 05/12/2023).

    icusbib[author = "delgado", date = "/1985"]

    ## [1] J. M. R. Delgado. "Biological bases on reality and imaginary". In:
    ## _Absolute Values and the New Cultural Revolution_. Thirteenth
    ## International Conference on the Unity of the Sciences. (J.W. Marriott
    ## Hotel, 9. 02, 1984-9. 05, 1984). chairpersonK. Mellanby, A. King and C.
    ## A. Villee Jr.. International Cultural Foundation. Washington, DC, USA,
    ## 1984.
    ## <https://icus.org/wp-content/uploads/2016/03/ICUS-XVIII-Program.pdf>
    ## (visited on 05/12/2023).
    ## 
    ## [2] J. M. R. Delgado. "Forms, symbols and the structure of the brain".
    ## In: _Absolute Values and the New Cultural Revolution_. Fourteenth
    ## International Conference on the Unity of the Sciences. (Hotel
    ## Intercontinental, 11. 28, 1985-12. 01, 1985). chairpersonK. Mellanby,
    ## T. R. Gerholm and A. King. International Cultural Foundation. Houston,
    ## TX, USA, 1985.
    ## <https://icus.org/wp-content/uploads/2016/02/ICUS-XIV-Program.pdf>
    ## (visited on 05/12/2023).
    ## 
    ## [3] J. M. R. Delgado. "Transmaterial values within the brain". In: _The
    ## responsibility of the academic community in the search for absolute
    ## values_. The Eighth International Conference on the Unity of the
    ## Sciences. (Century Plaza Hotel, 11. 22, 1979-11. 25, 1979).
    ## chairpersonE. P. Wigner and J. C. Eccles. With a comment. by S. L.
    ## Palay. International Cultural Foundation. Los Angeles, CA, 1979.
    ## <https://icus.org/wp-content/uploads/2016/02/ICUS-VIII-Program.pdf>
    ## (visited on 05/12/2023).

## Boolean OR in search (merge)

RefManageR provides Boolean OR capability through

See also `SearchBib()` in the [reference
manual](https://cloud.r-project.org/web/packages/RefManageR/RefManageR.pdf).

### Using the +.BibEntry operator

    length(icusbib[author = "Dagum"])

    ## [1] 4

    length(icusbib[commentator = "Dagum"])

    ## [1] 1

    sr <- icusbib[author = "Dagum"] + icusbib[commentator = "Dagum"]
    length(sr)

    ## [1] 5

### Using a list of lists

    icusbib[list(author = "delgado", title = "neurobiol", editora = "fukuda")]

    ## [1] J. M. R. Delgado. "Neurobiological factors in the development of
    ## personhood". In: _Absolute Values and the Reassessment of the
    ## Contemporary World_. Sixteenth International Conference on the Unity of
    ## the Sciences. (Stouffer Waverly Hotel, 11. 26, 1987-11. 29, 1987).
    ## chairpersonA. M. Weinberg, T. R. Gerholm and N. Fukuda. With a comment.
    ## by L. Rakic. International Cultural Foundation. Washington, DC, USA,
    ## 1987.
    ## <https://icus.org/wp-content/uploads/2016/02/ICUS-XVI-Program.pdf>
    ## (visited on 05/12/2023).

    icusbib[list(author = "delgado", title = "psychobiol", editora = "mellanby")]

    ## [1] J. M. R. Delgado. "Psychobiology of space and time". In: _Absolute
    ## Values and the New Cultural Revolution_. Fifteenth International
    ## Conference on the Unity of the Sciences. (J.W. Marriott Hotel, 11. 27,
    ## 1986-11. 30, 1986). chairpersonK. Mellanby, A. M. Weinberg and A. King.
    ## International Cultural Foundation. Washington, DC, USA, 1986.
    ## <https://icus.org/wp-content/uploads/2016/02/ICUS-XV-Program.pdf>
    ## (visited on 05/12/2023).

    icusbib[list(author = "delgado", title = "neurobiol", editora = "fukuda"),
              list(author = "delgado", title = "psychobiol", editora = "mellanby")]

    ## [1] J. M. R. Delgado. "Neurobiological factors in the development of
    ## personhood". In: _Absolute Values and the Reassessment of the
    ## Contemporary World_. Sixteenth International Conference on the Unity of
    ## the Sciences. (Stouffer Waverly Hotel, 11. 26, 1987-11. 29, 1987).
    ## chairpersonA. M. Weinberg, T. R. Gerholm and N. Fukuda. With a comment.
    ## by L. Rakic. International Cultural Foundation. Washington, DC, USA,
    ## 1987.
    ## <https://icus.org/wp-content/uploads/2016/02/ICUS-XVI-Program.pdf>
    ## (visited on 05/12/2023).
    ## 
    ## [2] J. M. R. Delgado. "Psychobiology of space and time". In: _Absolute
    ## Values and the New Cultural Revolution_. Fifteenth International
    ## Conference on the Unity of the Sciences. (J.W. Marriott Hotel, 11. 27,
    ## 1986-11. 30, 1986). chairpersonK. Mellanby, A. M. Weinberg and A. King.
    ## International Cultural Foundation. Washington, DC, USA, 1986.
    ## <https://icus.org/wp-content/uploads/2016/02/ICUS-XV-Program.pdf>
    ## (visited on 05/12/2023).

The following examples have the grammar: AUTHOR AND (TITLE1 OR TITLE2)
AND CHAIRPERSON.

    icusbib[author = "delgado"][list(title = "psychobiol"),list(title = "neurobiol")][editora = "weinberg"]

    ## [1] J. M. R. Delgado. "Neurobiological factors in the development of
    ## personhood". In: _Absolute Values and the Reassessment of the
    ## Contemporary World_. Sixteenth International Conference on the Unity of
    ## the Sciences. (Stouffer Waverly Hotel, 11. 26, 1987-11. 29, 1987).
    ## chairpersonA. M. Weinberg, T. R. Gerholm and N. Fukuda. With a comment.
    ## by L. Rakic. International Cultural Foundation. Washington, DC, USA,
    ## 1987.
    ## <https://icus.org/wp-content/uploads/2016/02/ICUS-XVI-Program.pdf>
    ## (visited on 05/12/2023).
    ## 
    ## [2] J. M. R. Delgado. "Neurobiology of global ideology and values". In:
    ## _Absolute Values and the Reassessment of the Contemporary World_.
    ## Seventeenth International Conference on the Unity of the Sciences.
    ## (Stouffer Concourse Hotel, 11. 24, 1988-11. 27, 1988). chairpersonA. M.
    ## Weinberg, M. Higatsberger and V. Cappelletti. International Cultural
    ## Foundation. Los Angeles, CA, USA, 1988.
    ## <https://icus.org/wp-content/uploads/2016/03/ICUS-XVII-Program.pdf>
    ## (visited on 05/12/2023).
    ## 
    ## [3] J. M. R. Delgado. "Psychobiology of space and time". In: _Absolute
    ## Values and the New Cultural Revolution_. Fifteenth International
    ## Conference on the Unity of the Sciences. (J.W. Marriott Hotel, 11. 27,
    ## 1986-11. 30, 1986). chairpersonK. Mellanby, A. M. Weinberg and A. King.
    ## International Cultural Foundation. Washington, DC, USA, 1986.
    ## <https://icus.org/wp-content/uploads/2016/02/ICUS-XV-Program.pdf>
    ## (visited on 05/12/2023).

    icusbib[author = "delgado"][list(title = "psychobiol"),list(title = "neurobiol")][editora = "king"]

    ## [1] J. M. R. Delgado. "Psychobiology of space and time". In: _Absolute
    ## Values and the New Cultural Revolution_. Fifteenth International
    ## Conference on the Unity of the Sciences. (J.W. Marriott Hotel, 11. 27,
    ## 1986-11. 30, 1986). chairpersonK. Mellanby, A. M. Weinberg and A. King.
    ## International Cultural Foundation. Washington, DC, USA, 1986.
    ## <https://icus.org/wp-content/uploads/2016/02/ICUS-XV-Program.pdf>
    ## (visited on 05/12/2023).

    icusbib[author = "delgado"][list(title = "psychobiol"),list(title = "neurobiol")][editora = "fukuda"]

    ## [1] J. M. R. Delgado. "Neurobiological factors in the development of
    ## personhood". In: _Absolute Values and the Reassessment of the
    ## Contemporary World_. Sixteenth International Conference on the Unity of
    ## the Sciences. (Stouffer Waverly Hotel, 11. 26, 1987-11. 29, 1987).
    ## chairpersonA. M. Weinberg, T. R. Gerholm and N. Fukuda. With a comment.
    ## by L. Rakic. International Cultural Foundation. Washington, DC, USA,
    ## 1987.
    ## <https://icus.org/wp-content/uploads/2016/02/ICUS-XVI-Program.pdf>
    ## (visited on 05/12/2023).

## Searches on keys are also regular expression matches.

    oldopts <- BibOptions(bib.style = "draft") # Draft style shows keys
    icusbib[key = "ICUS01:C01:G01:S01"]

    ## *ICUS01:C01:G01:S01* C. Dagum. "The Impact of Unified Science on
    ## Economics". In: _Moral Orientation of the Sciences_. First
    ## International Conference on Unified Science. (Waldorf-Astoria Hotel,
    ## 11. 23, 1972-11. 26, 1972). chairpersonE. Laszlo and E. Haskell.
    ## Council for Unified Research and Education. New York, New York, 1972.
    ## <https://icus.org/wp-content/uploads/2016/03/1st-ICUS-New-York-City-1972.pdf>
    ## (visited on 05/01/2023).

    icusbib[key = "ICUS01:C01:G01"][1:2]

    ## Set: ICUS01:C01:G01
    ## 
    ## *ICUS01:C01:G01:S01* C. Dagum. "The Impact of Unified Science on
    ## Economics". In: _Moral Orientation of the Sciences_. First
    ## International Conference on Unified Science. (Waldorf-Astoria Hotel,
    ## 11. 23, 1972-11. 26, 1972). chairpersonE. Laszlo and E. Haskell.
    ## Council for Unified Research and Education. New York, New York, 1972.
    ## <https://icus.org/wp-content/uploads/2016/03/1st-ICUS-New-York-City-1972.pdf>
    ## (visited on 05/01/2023).

    icusbib[key = "ICUS01:C01:G01$"] # $ matches end of line

    ## Set: ICUS01:C01:G01

    icusbib[key = "C01:G01:S01"][1:2]

    ## *ICUS01:C01:G01:S01* C. Dagum. "The Impact of Unified Science on
    ## Economics". In: _Moral Orientation of the Sciences_. First
    ## International Conference on Unified Science. (Waldorf-Astoria Hotel,
    ## 11. 23, 1972-11. 26, 1972). chairpersonE. Laszlo and E. Haskell.
    ## Council for Unified Research and Education. New York, New York, 1972.
    ## <https://icus.org/wp-content/uploads/2016/03/1st-ICUS-New-York-City-1972.pdf>
    ## (visited on 05/01/2023).
    ## 
    ## *ICUS02:C01:G01:S01* Y. Bar-Hillel. "Unity of Science - 1973". In:
    ## _Modern Science and Moral Values_. Second International Conference on
    ## the Unity of the Sciences. (Imperial Hotel, 11. 18, 1973-11. 21, 1973).
    ## chairpersonN. Sawada and N. Yosida. International Cultural Foundation.
    ## Tokyo, Japan, 1973.
    ## <https://icus.org/wp-content/uploads/2015/10/ICUSII-Program.pdf>
    ## (visited on 05/08/2023).

    icusbib[key = "^C01:G01:S01"][1:2] # ^ matches beginning of line

    ## No results.

    ## [[1]]
    ## NULL
    ## 
    ## [[2]]
    ## NULL

    BibOptions(oldopts)

# References

Bengtsson, Henrik. 2023. *R.utils: Various Programming Utilities*.
<https://henrikbengtsson.github.io/R.utils/>.

Engel, Alan. 2024. “Moonism and Science.” OSF.
<https://doi.org/10.17605/OSF.IO/S2PTW>.

*International Conference on the Unity of the Sciences - History*. 2020.
ICUS. <https://icus.org/about-2/history/>.

Lehman, Philipp, Philip Kime, Audrey Boruvka, and Joseph Wright. 2022.
“The <span class="nocase">b</span>iblatex Package.”
<https://mirrors.ibiblio.org/CTAN/macros/latex/contrib/biblatex/doc/biblatex.pdf>.

McLean, Mathew W. 2014. “Straightforward Bibliography Management in R
Using the RefManageR Package.” <https://arxiv.org/abs/1403.2036>.

Patashnik, Oren. 1988. “Bibtexing.”
<http://bibtexml.sourceforge.net/btxdoc.pdf>.

R Core Team. 2023. *R: A Language and Environment for Statistical
Computing*. Vienna, Austria: R Foundation for Statistical Computing.
<https://www.R-project.org/>.
