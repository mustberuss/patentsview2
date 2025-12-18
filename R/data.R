#' @title data frame of CPC classifications
#' @description cpc_subgroups is a custom data frame of CPC classifications built from the bulk file
#' acknowledged below.
#' @format 
#' \describe{
#'   \item{id}{cpc subclass}
#'   \item{title}{cpc subgroup title}
#'   \item{cpc_subclass}{cpc subclass}
#'   \item{cpc_group}{cpc group}
#'   \item{cpc_subgroup}{cpc subgroup}
#' }
#'
#' @source
#' Data loaded from g_cpc_title.tsv.zip in the \href{patentsview.org/download/data-download-tables}{Patentsview API's bulk data files}. Acknowledged here per its Creative Commons Attribution 4.0 License. 
#' All of the rows are used but the columns have been manipulated as can be seen in data-raw/get_cpc_data.R
#' @docType data
#' @keywords datasets
#' @name cpc_subgroups
#' @usage data(cpc_subgroups)
#'
#' @examples
#' data(cpc_subgroups)
#' head(cpc_subgroups)
NULL

#' @title data frame of unique CPC subclasses
#' @description cpc_subclasses is a data frame of unique CPC subclasses found in \link{cpc_subgroups}
#' It's the distinct(cpc_subclass,title) where the cpc_subgroup is "00" and
#' the cpc_group is either "1" or "10"
#' @format
#' \describe{
#'   \item{cpc_subclass}{cpc subclass}
#'   \item{title}{cpc subclass title}
#' }
#'
#' @docType data
#' @keywords datasets
#' @name cpc_subclasses
#' @usage data(cpc_subclasses)
#' @examples
#' data(cpc_subclasses)
#' head(cpc_subclasses)
NULL
