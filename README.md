## NOTICE: This package was built for the PatentsView Legacy API, which has been discontinued as of May 1 2025. As a result... none of it works anymore. I will hopefully get around to updating it sometime in 2025.

# patentsview2

`patentsview2` is a simple set of functions to query the [Patent
endpoint](https://search.patentsview.org/docs/docs/Search%20API/EndpointDictionary/#patent)
of the [PatentsView API](https://patentsview.org/) using [CPC
Subclass](https://en.wikipedia.org/wiki/Cooperative_Patent_Classification)
identifiers (e.g. [G16H for medical
informatics](https://www.uspto.gov/web/patents/classification/cpc/html/cpc-G16H.html#G16H)).

As promised, this package was reworked to use the new version of the
Patentsview API (renamed the PatentSearch API, as announced
[here](https://search.patentsview.org/docs/#naming-update)). We’re also
using the [updated patentview R
package](https://mustberuss.github.io/patentsview/) though it’s not on
CRAN yet.

# introduction

Patents and patent applications are a valuable measure of innovation
within countries, sub-national geographies (e.g. states or cities),
industries, and firms. Numerous patent databases exist, including
[PATSTAT from the EPO](https://data.epo.org/expert-services/index.html),
[NBER](https://www.nber.org/research/data/us-patents), [Google
Patents](https://patents.google.com/), [OECD Patent
Microdata](https://www.oecd.org/sti/intellectual-property-statistics-and-analysis.htm),
[the USPTO](https://www.uspto.gov/patents/search), and
[others](https://iii.pubpub.org/datasets). These databases can be
unweildy, so the USPTO created [PatentsView](https://patentsview.org/)
as a user-friendly query portal for data about individual patents. They
also implemented several API endpoints that can be queried directly.
Despite its public availability and documentation, the PatentsView API
isn’t *that* easy to use. So to collect data about patents across
different patent types, classified by Cooperative Patent Classification
(CPC) subclasses, I wrote a few helper functions. Hope they’re useful.

# installation steps

1.  API team now requires an API key so you’ll need to [request
    one](https://patentsview-support.atlassian.net/servicedesk/customer/portals)
    before any of this will work. The new version of the patentsview R
    package looks for its value in the environmental variable
    PATENTSVIEW_API_KEY. Please be careful when posting scripts to not
    include the value of your API key.

2.  Install the new version of the Patentsview R package from r-universe

    ``` r
    install.packages("patentsview", repos = c("https://mustberuss.r-universe.dev"))
    ```

3.  Install the dev version of this package, patentsview2, from github

    ``` r
    if (!"devtools" %in% rownames(installed.packages())) {
      install.packages("devtools")
    }

    devtools::install_github("nateapathy/patentsview2")
    ```

# the `patents_view()` function

`patentsview2::patents_view()` is the primary function. This function
calls two other functions, `pv_post()` and `clean_patents()`. This
function has a single argument, `cpc`, which takes a string consisting
of any of the 4-character CPC subclasses available in PatentsView. By
default, the function returns all patent applications with the defined
classification since Jan 1, 2001 to the USPTO by US-based assignees. The
earliest patent application in the database is 200100000012

``` r
library(patentsview2)

patents_view(cpc = "F03B")
```

This returns a data frame of patent application observations and 30
fields of information about the patent as well as the inventors and
assignees.

## `pv_post()` and `clean_patents()`

You should not have to call either of these functions directly. Both are
called by `patents_view()` to help with constructing the POST call to
the API and to clean up the data frame, as their names imply.

# the CPC datasets

The package also includes two data sets for reference to CPC subclasses.
`cpc_subgroups` lists all subclasses, groups, and subgroups (258,827
observations), while `cpc_subclasses` lists only the four-character
subclass codes (615 observations) that can be used in the `cpc` argument
within `patents_view()`.

``` r
data("cpc_subclasses") # 615 obs by 2 vars
data("cpc_subgroups") # 258,827 obs by 5 vars
```

Use `cpc_subclasses` to find subclasses of interest, and use the
4-character code found in the `cpc_subclass` field in your query. You
can also [browse the CPC hierarchy from the
USPTO](https://www.uspto.gov/web/patents/classification/cpc/html/cpc.html).
You may also want to loop through several CPC subclasses, as below. Note
that the below code does not look for patents with all subclasses, but
rather performs distinct API calls for each of the 5 random CPC
subclasses sampled. In this case, the 5 data frames will all be in the
`random_cpcs` list.

``` r
# random sample of CPCs
cpc_samp <- sample(cpc_subclasses$cpc_subclass, 5)
random_cpcs <- list()
for (i in c(1:length(cpc_samp))) {
  random_cpcs[[i]] <- patents_view(cpc = cpc_samp[i])
}
names(random_cpcs) <- cpc_samp
```

# an example

``` r
# CPC Subclass B62K: Unicycles
cpc_subclasses %>% filter(cpc_subclass == "B62K")
#>   cpc_subclass     title
#> 1         B62K Unicycles
b62k <- patents_view(cpc = "B62K")
dim(b62k)
#> [1] 2668   42
# patent applications since Jan 1 2000

# get number of unique patient numbers
# remember, each observation is an APPLICATION not a patent
unique(b62k$patent_number) %>% length()
#> [1] 0

# how many unique first assignees?
unique(b62k$assignee_organization) %>% length()
#> [1] 17

# what other fields do we have?
colnames(b62k)
#>  [1] "patent_id"                                                   
#>  [2] "patent_title"                                                
#>  [3] "patent_type"                                                 
#>  [4] "patent_date"                                                 
#>  [5] "patent_year"                                                 
#>  [6] "patent_abstract"                                             
#>  [7] "patent_cpc_current_group_average_patent_processing_days"     
#>  [8] "withdrawn"                                                   
#>  [9] "patent_detail_desc_length"                                   
#> [10] "patent_earliest_application_date"                            
#> [11] "patent_num_foreign_documents_cited"                          
#> [12] "patent_num_times_cited_by_us_patents"                        
#> [13] "patent_num_total_documents_cited"                            
#> [14] "patent_num_us_applications_cited"                            
#> [15] "patent_num_us_patents_cited"                                 
#> [16] "patent_processing_days"                                      
#> [17] "patent_term_extension"                                       
#> [18] "gov_interest_statement"                                      
#> [19] "patent_uspc_current_mainclass_average_patent_processing_days"
#> [20] "wipo_kind"                                                   
#> [21] "inventor"                                                    
#> [22] "inventor_id"                                                 
#> [23] "inventor_name_first"                                         
#> [24] "inventor_name_last"                                          
#> [25] "inventor_gender_code"                                        
#> [26] "inventor_location_id"                                        
#> [27] "inventor_city"                                               
#> [28] "inventor_state"                                              
#> [29] "inventor_country"                                            
#> [30] "inventor_sequence"                                           
#> [31] "inv_city_state"                                              
#> [32] "assignee"                                                    
#> [33] "assignee_id"                                                 
#> [34] "assignee_type"                                               
#> [35] "assignee_individual_name_first"                              
#> [36] "assignee_individual_name_last"                               
#> [37] "assignee_organization"                                       
#> [38] "assignee_location_id"                                        
#> [39] "assignee_city"                                               
#> [40] "assignee_state"                                              
#> [41] "assignee_country"                                            
#> [42] "assignee_sequence"

# where are unicycle patent applications concentrated?
b62k %>%
  group_by(inv_city_state) %>%
  tally() %>%
  arrange(desc(n)) %>%
  ungroup() %>%
  mutate(
    pct = n / sum(n) * 100,
    cumulative_pct = cumsum(pct)
  ) %>%
  top_n(10, n) %>%
  kable()
```

| inv_city_state       |   n |      pct | cumulative_pct |
|:---------------------|----:|---------:|---------------:|
| Santa Cruz, CA       |  89 | 3.335832 |       3.335832 |
| Chicago, IL          |  77 | 2.886057 |       6.221889 |
| Bedford, NH          |  73 | 2.736132 |       8.958021 |
| Capitola, CA         |  70 | 2.623688 |      11.581709 |
| San Francisco, CA    |  68 | 2.548726 |      14.130435 |
| Los Gatos, CA        |  65 | 2.436282 |      16.566717 |
| معلمی نژاد, CA       |  56 | 2.098950 |      18.665667 |
| Roseau, MN           |  37 | 1.386807 |      20.052474 |
| Madison, WI          |  36 | 1.349325 |      21.401799 |
| Colorado Springs, CO |  34 | 1.274363 |      22.676162 |

And now that we are using the patentsview R package, we can do other
interesting things like figuring out which of the applications in B62K
have become patents. This can potentially change every time we run this
query as more and more patent applications become issued patents and as
new applications are classified with a subclass of B62K.

(Functions to do the post and clean below could be added to this
package!)

``` r
# Granted patent data is available from the API for 1976 onward,
# as it was in the original version of the API.  With the new
# version of the API, application data is also available for 2001 onward.

# Here we'll make a query to the new publication endpoint with functionally
# the same parameters as pv_post() makes to the patent endpoint
application_query <- patentsview::with_qfuns(
  and(
    gte(publication_date = "2001-01-01"),
    eq(cpc_current.cpc_subclass_id = "B62K"),
    eq(assignees.assignee_country = "US")
  )
)

fields_to_return <- c("assignees", "inventors", "cpc_at_issue")
patent_applications <- patentsview::search_pv(application_query, endpoint = "publication", fields = fields_to_return, all_pages = TRUE)
nrow(patent_applications$data$publications)
#> [1] 1349
unnested <- patentsview::unnest_pv_data(patent_applications$data)
unnested
#> List of 4
#>  $ assignees   :'data.frame':    1363 obs. of  12 variables:
#>   ..$ document_number               : chr [1:1363] "20020148323" ...
#>   ..$ assignee                      : chr [1:1363] "https://search.patentsvie"..
#>   ..$ assignee_id                   : chr [1:1363] "ceecf12f-afad-4fd3-9dfc-8"..
#>   ..$ assignee_type                 : chr [1:1363] "2" ...
#>   ..$ assignee_individual_name_first: chr [1:1363] NA ...
#>   ..$ assignee_individual_name_last : chr [1:1363] NA ...
#>   ..$ assignee_organization         : chr [1:1363] "L.H. Thomson Company, Inc"..
#>   ..$ assignee_location_id          : chr [1:1363] "ef5e39b0-16c7-11ed-9b5f-1"..
#>   ..$ assignee_city                 : chr [1:1363] "Macon" ...
#>   ..$ assignee_state                : chr [1:1363] "GA" ...
#>   ..$ assignee_country              : chr [1:1363] "US" ...
#>   ..$ assignee_sequence             : int [1:1363] 1 1 ...
#>  $ inventors   :'data.frame':    3398 obs. of  11 variables:
#>   ..$ document_number     : chr [1:3398] "20020148323" ...
#>   ..$ inventor            : chr [1:3398] "https://search.patentsview.org:80/a"..
#>   ..$ inventor_id         : chr [1:3398] "fl:br_ln:thomson-9" ...
#>   ..$ inventor_name_first : chr [1:3398] "Brian" ...
#>   ..$ inventor_name_last  : chr [1:3398] "Thomson" ...
#>   ..$ inventor_gender_code: chr [1:3398] "M" ...
#>   ..$ inventor_location_id: chr [1:3398] "ed8ff011-16c7-11ed-9b5f-1234bde3cd0"..
#>   ..$ inventor_city       : chr [1:3398] "Warner Robins" ...
#>   ..$ inventor_state      : chr [1:3398] "GA" ...
#>   ..$ inventor_country    : chr [1:3398] "US" ...
#>   ..$ inventor_sequence   : int [1:3398] 1 0 ...
#>  $ cpc_at_issue:'data.frame':    4118 obs. of  9 variables:
#>   ..$ document_number: chr [1:4118] "20130092465" ...
#>   ..$ cpc_sequence   : int [1:4118] 1 2 ...
#>   ..$ cpc_class      : chr [1:4118] "https://search.patentsview.org:80/api/v1"..
#>   ..$ cpc_class_id   : chr [1:4118] "B62" ...
#>   ..$ cpc_subclass   : chr [1:4118] "https://search.patentsview.org:80/api/v1"..
#>   ..$ cpc_subclass_id: chr [1:4118] "B62K" ...
#>   ..$ cpc_group      : chr [1:4118] "https://search.patentsview.org:80/api/v1"..
#>   ..$ cpc_group_id   : chr [1:4118] "B62K15/008" ...
#>   ..$ action_date    : chr [1:4118] "2013-04-18" ...
#>  $ publications:'data.frame':    1349 obs. of  1 variable:
#>   ..$ document_number: num [1:1349] 2e+10 ...

# The new version of the API does not have publication_firstnamed_inventor_city
# or publication_firstnamed_inventor_state so we'll getting them from
# the first inventor (inventor_sequence of zero)

# document_number is a string in inventors and numeric in publications
# first inventor: min(unnested[["inventors"]]$inventor_sequence) is 0
first_inventors <- unnested[["inventors"]] %>%
  dplyr::filter(inventor_sequence == 0) %>%
  dplyr::mutate(inv_city_state = paste0(inventor_city, ", ", ifelse(is.na(inventor_state), inventor_country, inventor_state))) %>%
  dplyr::mutate(document_number = as.numeric(document_number))

# document_number is a string in assignees and numeric in publications
# first assignee: min(unnested[["assignees"]]$assignee_sequence) is 1
first_assignees <- unnested[["assignees"]] %>%
  dplyr::filter(assignee_sequence == 1) %>%
  dplyr::mutate(document_number = as.numeric(document_number))

publications <- unnested[["publications"]] %>%
  dplyr::inner_join(first_inventors, by = "document_number") %>%
  dplyr::left_join(first_assignees, by = "document_number")

dim(publications)
#> [1] 1349   23
colnames(publications)
#>  [1] "document_number"                "inventor"                      
#>  [3] "inventor_id"                    "inventor_name_first"           
#>  [5] "inventor_name_last"             "inventor_gender_code"          
#>  [7] "inventor_location_id"           "inventor_city"                 
#>  [9] "inventor_state"                 "inventor_country"              
#> [11] "inventor_sequence"              "inv_city_state"                
#> [13] "assignee"                       "assignee_id"                   
#> [15] "assignee_type"                  "assignee_individual_name_first"
#> [17] "assignee_individual_name_last"  "assignee_organization"         
#> [19] "assignee_location_id"           "assignee_city"                 
#> [21] "assignee_state"                 "assignee_country"              
#> [23] "assignee_sequence"
```

There’s more information on the patentsview R package
[here](https://github.com/ropensci/patentsview) (not yet updated for the
new verion)
