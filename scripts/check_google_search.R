#!/usr/bin/env Rscript
# Simple helper to validate Google Custom Search credentials and display a sample formatted result
args <- commandArgs(trailingOnly = TRUE)
query <- if (length(args) >= 1) paste(args, collapse = " ") else "test query"

# Ensure working directory is project root when run from project
suppressPackageStartupMessages({
  library(readr)
})

# Try to source app utils
if (file.exists("app/utils/functions.R")) {
  source("app/utils/functions.R")
} else if (file.exists("utils/functions.R")) {
  source("utils/functions.R")
} else {
  cat("Cannot find functions.R. Run this script from project root where app/utils/functions.R exists.\n")
  quit(status = 1)
}

res <- perform_google_search(query)

if (is.list(res) && !is.null(res$error)) {
  cat("ERROR:", res$error, "\n")
  quit(status = 2)
}

cat("Formatted results:\n\n")
cat(format_search_results(res, max_results = 3), "\n")

invisible(NULL)
# Simple check for Google Custom Search env vars and a sample query

api_key <- Sys.getenv("google_search_api_key", unset = NA)
cx <- Sys.getenv("google_search_engine_id", unset = NA)

if (is.na(api_key) || is.na(cx) || !nzchar(api_key) || !nzchar(cx)) {
  cat("Missing google_search_api_key or google_search_engine_id.\n")
  cat("Set them in your .Renviron or export them in the shell, then restart R.\n")
  quit(status = 1)
}

library(httr2)

resp <- httr2::request("https://www.googleapis.com/customsearch/v1") |>
  httr2::req_url_query(key = api_key, cx = cx, q = "R Shiny tutorial") |>
  httr2::req_perform()

if (httr2::resp_is_error(resp)) {
  cat("Google search request failed:\n")
  print(httr2::resp_status(resp))
  quit(status = 2)
}

data <- httr2::resp_body_json(resp)
if (!is.null(data$items) && length(data$items) > 0) {
  cat("Sample search succeeded. Top result:\n")
  print(data$items[[1]]$title)
  print(data$items[[1]]$link)
} else {
  cat("No results returned for the sample query.\n")
}
