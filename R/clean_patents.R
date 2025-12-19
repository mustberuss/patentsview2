#' @title Flattens the data returned by the PatentsView API
#'
#' @description This function formats the returned JSON objects into flat data frames
#'
#' @param pvresult The return from pv_post()1
#'
#' @return a data frame of 38 fields
#'
#' @examples 
#' pvresult <- pv_post("2024-01-01", cpc="G16H")
#' clean_patents(pvresult)
#' @export

########################################
########### clean_patents() ############
########################################
clean_patents <- function(pvresult) {
  # we can't unpack both inventors and assignees - could be of different 
  # sizes and assignees could be null
  unnested <- patentsview::unnest_pv_data(pvresult$data)

  # create a list of the first inventors and assignees and join them
  # back in. the first inventor is inventor_sequence of zero
  first_inventors <- unnested[["inventors"]] %>%
    dplyr::filter(inventor_sequence == 0) %>%
    dplyr::mutate(inv_city_state = paste0(inventor_city, ", ", ifelse(is.na(inventor_state), inventor_country, inventor_state)))

  # first assignee: min(unnested[["assignees"]]$assignee_sequence) is 1
  first_assignees <- unnested[["assignees"]] %>%
    dplyr::filter(assignee_sequence == 1)

  patents <- unnested[["patents"]] %>%
    dplyr::inner_join(first_inventors,  by = "patent_id") %>%
    dplyr::left_join(first_assignees,  by = "patent_id")

  return(patents)
}

# similar function for patent applications - export if it would be handy
#' @noRd
clean_publications <- function(pvresult) {

  # we can't unpack both inventors and assignees - could be of different 
  # sizes and assignees could be null
  unnested <- patentsview::unnest_pv_data(pvresult$data)

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
    dplyr::inner_join(first_inventors,  by = "document_number") %>%
    dplyr::left_join(first_assignees,  by = "document_number")

  return(publications)
}

