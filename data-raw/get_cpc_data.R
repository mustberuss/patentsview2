#### Get CPC Data for Reference table, create .rda file for lazy loading
## cpc_subgroup file from https://www.patentsview.org/download/
library(tidyverse)
library(stringr)
library(usethis)
# download and unzip the file
temp <- tempfile()
# this link should be steady but may change if file gets updated ;-)
download.file("https://s3.amazonaws.com/data.patentsview.org/download/g_cpc_title.tsv.zip",temp)
cpc_subgroups <- read.delim(unzip(temp, "g_cpc_title.tsv", exdir = tempdir()))
unlink(temp)
rm(temp)

# in the new data file cpc_group is the full classification, what was id prevously
# and we have a cpc_subclass, we don't need to create it

# from the original version
# get the ID in to subclass (first 4 characters), group (next 1-3), 
# and subgroup (after the /)

cpc_subgroups %>%
  rename(id = cpc_group, title = cpc_group_title) %>%
  mutate(cpc_subgroup = sub("[[:alnum:]]+/([[:alnum:]]+)$", "\\1", id),
         cpc_group = sub("^[[:alnum:]]{4}(.+)/.+$", "\\1", id)) %>%
  select(id, title, cpc_subclass, cpc_group, cpc_subgroup) -> cpc_subgroups

use_data(cpc_subgroups, internal = FALSE, overwrite = TRUE)

# filter down to subclass only
cpc_subgroups %>%
  filter(cpc_subgroup=="00" & cpc_group %in% c("1","10")) %>%
  distinct(cpc_subclass,title) %>%
  dplyr::select(c(1,2)) -> cpc_subclasses

use_data(cpc_subclasses, internal = FALSE, overwrite = TRUE)
# write a csv too?
#write.csv(cpc_subclasses, 'data/cpc_subclasses.csv', row.names = FALSE)
