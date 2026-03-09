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

# Optional: bcrypt for password hashing
if (requireNamespace("bcrypt", quietly = TRUE)) {
  library(bcrypt)
  cat("bcrypt loaded: passwords will be hashed\n")
} else {
  cat("WARNING: bcrypt not installed. Passwords stored as plaintext.\n")
  cat("Install with: install.packages('bcrypt')\n")
}

source("utils/functions.R")
source("login_ui.R")
source("chat_ui.R")

# Check required environment variables at startup
ENV_VARS_STATUS_MSG <- missing_env_vars_message()

# ---- AWS CONFIGURATION ----
Sys.setenv(
  "AWS_ACCESS_KEY_ID" = Sys.getenv("AWS_ACCESS_KEY_ID"),
  "AWS_SECRET_ACCESS_KEY" = Sys.getenv("AWS_SECRET_ACCESS_KEY"),
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

# ---- APP CONFIGURATION ----
MAX_FILE_SIZE_MB <- 10
MAX_CONVERSATION_HISTORY <- 10

# Ensure admin account exists (hash password if bcrypt available)
creds <- get_credentials()
# if (!all(c("user", "password") %in% names(creds))) {
#   creds <- data.frame(user = character(0), password = character(0), stringsAsFactors = FALSE)
# }
# if (!(admin_user %in% creds$user)) {
#   hashed_pw <- hash_password(admin_password)
#   new_row <- data.frame(user = admin_user, password = hashed_pw, stringsAsFactors = FALSE)
#   creds <- rbind(creds, new_row)
#   save_credentials(creds)
# }
