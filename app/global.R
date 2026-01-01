# Set OPENAI_API_KEY from MIA's variable, if present
lucy_key <- Sys.getenv("OPENAI_API_LUCY_SHINY", unset = NA)
if (!is.na(lucy_key) && nchar(lucy_key) > 0) {
  Sys.setenv(OPENAI_API_KEY = lucy_key)
}

library(shiny)
library(shinyWidgets)
library(bslib)
library(purrr)
library(glue)
library(ellmer)
library(shinychat)
library(base64enc)
library(tools)
library(png)
library(jpeg)
library(aws.s3)
library(shinyjs)
library(readr)
library(magick)
library(openxlsx)
library(pdftools)
library(officer)
library(markdown)

source("utils/functions.R")
source("login_ui.R")
source("chat_ui.R")

# Check required environment variables at startup and expose a status message
ENV_VARS_STATUS_MSG <- missing_env_vars_message()

# ---- AWS CONFIGURATION ----
Sys.setenv(
  "AWS_ACCESS_KEY_ID" = Sys.getenv("personal_aws_access_key"),
  "AWS_SECRET_ACCESS_KEY" = Sys.getenv("personal_aws_secret_key"),
  "AWS_DEFAULT_REGION" = "us-west-1"
)
bucket_name <- Sys.getenv("s3ytfeedapp")
credentials_key <- "lucy-credentials.csv"

# ---- AWS Helpers ----
get_credentials <- function() {
  obj <- try(get_object(credentials_key, bucket_name), silent = TRUE)
  if (inherits(obj, "try-error") || is.null(obj)) {
    data.frame(user = character(), password = character(), stringsAsFactors = FALSE)
  } else {
    read.csv(text = rawToChar(obj), stringsAsFactors = FALSE)
  }
}

save_credentials <- function(df) {
  tmp <- tempfile(fileext = ".csv")
  write.csv(df, tmp, row.names = FALSE)
  put_object(file = tmp, object = credentials_key, bucket = bucket_name)
}

# Ensure admin account exists
admin_user <- "admin"
admin_password <- "pwd123"
creds <- get_credentials()
if (!all(c("user", "password") %in% names(creds))) {
  creds <- data.frame(user = character(0), password = character(0), stringsAsFactors = FALSE)
}
if (!(admin_user %in% creds$user)) {
  new_row <- data.frame(user = admin_user, password = admin_password, stringsAsFactors = FALSE)
  creds <- rbind(creds, new_row)
  save_credentials(creds)
}
