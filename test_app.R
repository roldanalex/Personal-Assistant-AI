# Test script for Lucy AI Assistant
# Run this to test if the app works after the fixes

# Check if required packages are installed
required_packages <- c(
  "shiny", "shinyWidgets", "bslib", "purrr", "glue", 
  "ellmer", "shinychat", "base64enc", "tools", 
  "png", "jpeg", "aws.s3", "shinyjs", "httr2"
)

missing_packages <- required_packages[!required_packages %in% rownames(installed.packages())]

if (length(missing_packages) > 0) {
  cat("Missing packages:", paste(missing_packages, collapse = ", "), "\n")
  cat("Installing missing packages...\n")
  install.packages(missing_packages)
} else {
  cat("All required packages are installed!\n")
}

# Check environment variables
required_env_vars <- c("OPENAI_API_LUCY_SHINY", "personal_aws_access_key", "personal_aws_secret_key", "s3ytfeedapp")
missing_env_vars <- required_env_vars[Sys.getenv(required_env_vars) == ""]

if (length(missing_env_vars) > 0) {
  cat("\nMissing environment variables:\n")
  for (var in missing_env_vars) {
    cat("-", var, "\n")
  }
  cat("\nPlease set these in your .Renviron file\n")
} else {
  cat("All environment variables are set!\n")
}

# Test the functions
cat("\nTesting core functions...\n")
source("app/utils/functions.R")

# Test system prompt function
test_prompt <- get_system_prompt("general")
cat("System prompt test:", substr(test_prompt, 1, 50), "...\n")

cat("\nIf no errors above, try running the app:\n")
cat("setwd('app')\n")
cat("shiny::runApp()\n")
cat("\nDefault login: admin / pwd123\n")