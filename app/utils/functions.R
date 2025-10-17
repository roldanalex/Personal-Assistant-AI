# Load required libraries for this file
library(bslib)

my_theme <- bs_theme(
  bootswatch = "darkly",
  heading_font = font_google("Lobster"),
  base_font = font_collection(
    font_google("Roboto Slab"), font_google("Merriweather")
  ),
  code_font = font_google("Inconsolata")
)

get_system_prompt <- function(task) {
  # Safety: fallback prompt
  if (missing(task) || is.null(task) || is.na(task) || !nzchar(task))
    task <- "general"

  # Define the path to markdown files
  markdown_dir <- file.path("..", "markdown")

  # Map task to markdown file
  file_mapping <- list(
    general = "general.md",
    r_code = "r_code.md",
    python_code = "python_code.md",
    sql_code = "sql_code.md",
    agente_primaria = "agente_primaria.md"
  )

  # Get the corresponding markdown file
  markdown_file <- file_mapping[[as.character(task)]]

  if (is.null(markdown_file)) {
    # Fallback to general if task not found
    markdown_file <- "general.md"
  }

  # Construct full path
  file_path <- file.path(markdown_dir, markdown_file)

  # Try to read the markdown file
  tryCatch({
    if (file.exists(file_path)) {
      content <- readr::read_file(file_path)
      return(content)
    } else {
      # Fallback prompts if files don't exist
      fallback_prompts <- list(
        general = "You are Lucy, a helpful AI learning assistant. Respond in a friendly, professional tone and help users learn effectively.",
        r_code = "You are Lucy, an expert R programming mentor. Provide clear, well-commented R code with explanations.",
        python_code = "You are Lucy, an expert Python programming mentor. Provide clean, Pythonic code with detailed explanations.",
        sql_code = "You are Lucy, an expert SQL database consultant. Provide efficient, well-formatted SQL queries with explanations.",
        agente_primaria = "Eres Lucy, un asistente educativo especializado en educación primaria peruana. Ayuda con todas las áreas curriculares siguiendo el Currículo Nacional del Perú."
      )
      
      # Use the task-specific fallback or general as final fallback
      task_prompt <- fallback_prompts[[as.character(task)]]
      if (is.null(task_prompt)) {
        task_prompt <- fallback_prompts[["general"]]
      }
      return(task_prompt)
    }
  }, error = function(e) {
    # Final fallback in case of any errors
    return("You are Lucy, a helpful AI assistant. Respond in a friendly, professional tone.")
  })
}

# Chat response function for OpenAI API (legacy support)
chat_response <- function(
  user_message, history = NULL,
  system_prompt = c("general", "r_code", "python_code", "sql_code"),
  api_key = Sys.getenv("OPENAI_API_LUCY_SHINY"),
  model_selected = "gpt-3.5-turbo") {

    system <- get_system_prompt(system_prompt)
    prompt <- prepare_prompt(user_message, system, history)

    body <- list(
      model = model_selected,
      messages = prompt
    )

    resp <- httr2::request("https://api.openai.com/v1/chat/completions") |>
      httr2::req_headers(
        Authorization = paste("Bearer", api_key),
        `Content-Type` = "application/json"
      ) |>
      httr2::req_user_agent("Alexis Roldan @roldanalex | Personal Chatbot") |>
      httr2::req_body_json(body) |>
      httr2::req_retry(max_tries = 4) |>
      httr2::req_throttle(rate = 15) |>
      httr2::req_perform()

    openai_chat_response <- resp |> httr2::resp_body_json(simplifyVector = TRUE)

    openai_chat_response$choices$message$content
}

prepare_prompt <- function(user_message, system_prompt, history) {
  user_prompt <- list(list(role = "user", content = user_message))

  c(system_prompt, history, user_prompt) |>
    purrr::compact()
}

update_history <- function(history, user_message, response) {
  c(
    history,
    list(
      list(role = "user", content = user_message),
      list(role = "assistant", content = response)
    )
  ) |> purrr::compact()
}