#' @title Queries PatentsView API by CPC
#'
#' @description This function submits requests to the PatentsView API to return information on patent applications by CPC code. It calls both pv_post() and clean_patents().
#'
#' @param cpc
#'
#' @return a data frame of 38 fields
#'
#' @examples patents_view(cpc="G16H", from="2023-01-01")
#'
#' @export patents_view

########################################
########### patents_view() #############
########################################
patents_view <- function(cpc,from="2000-01-01") {

  results <- pv_post(start_date = from, cpc = cpc)
  return(clean_patents(results))

}

