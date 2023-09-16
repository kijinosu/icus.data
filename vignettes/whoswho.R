## ----whoswho------------------------------------------------------------------
library(dplyr)
library(googlesheets4)
library(data.table)
gs4_auth(scopes = "spreadsheets.readonly") 
ss <- "https://docs.google.com/spreadsheets/d/1l8y_tp55rojn73308TTLr2yq_nZaeJC5v6CnKrZvS0s/edit?usp=sharing"
ww <- read_sheet(ss,sheet="Intl Who’s Who", na="N", trim_ws=TRUE)
ww1 <- as.data.table(ww)
write.table(ww1, file = file.path(project_path(),"data-raw","whoswho.tsv"), row.names=FALSE, sep="\t")
whoswho <- melt(ww1, id.vars = c("Surname","Given"),
            measure.vars=c("IntlWW40","IntlWW50","IntlWW60"),
             variable.name = "variable", 
             value.name = "value", na.rm=TRUE)

