#' @title Posts to the Patentsview API by CPC
#'
#' @description This function formats and submits a POST call to the PatentsView Patent API endpoint
#'
#' @param start_date
#'
#' @returns what we got back from the patentsview API
#'
#' @examples 
#' result <- pv_post("2024-01-01", cpc="G16H")
#' colnames(result)
#' @export

########################################
########### pv_post() ##################
########################################
pv_post <- function(start_date, cpc, env = parent.frame(),...) {

  # any assignee or just the first one?
  query <- patentsview::with_qfuns(
    and(
      gte(patent_earliest_application_date = start_date),
      eq(cpc_current.cpc_subclass_id = "B62K"),
      eq(assignees.assignee_country = "US")
    )
  )

  fields <- patentsview::get_fields("patent", group = c("patents", "inventors", "assignees", "cpc_current"))

  # get all pages of results, the R package will retry if throttled by the API
  results <- patentsview::search_pv(query, fields = fields, all_pages = TRUE, method = "POST", ...)

  return(results)
}


#' @noRd
pv_app_post <- function(start_date = "2001-01-01", cpc, env = parent.frame(),...) {
  # build the query and list of fields we want back from the API
  # any assignee or first assignee?
  query <- patentsview::with_qfuns(
    and(
      gte(publication_date = start_date), # all patents applied for since start_date
      eq(cpc_at_issue.cpc_subclass_id = cpc),
      eq(assignees.assignee_country = "US") # only from US applicants
    )
  )

  fields <- patentsview::get_fields("publication", groups = c("publications", "assignees", "inventors", "cpc_at_issue"))

  # get all pages of results, the R package will retry if throttled by the API
  results <- patentsview::search_pv(query, endpoint = "publication", fields = fields, all_pages = TRUE, method = "POST", ...)
  return (results)
}
