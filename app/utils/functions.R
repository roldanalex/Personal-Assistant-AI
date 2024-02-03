my_theme <- bs_theme(
  bootswatch = "darkly",
  heading_font = font_google("Lobster"),
  base_font = font_collection(
    font_google("Roboto Slab"), font_google("Merriweather")
  ),
  code_font = font_google("Inconsolata")
)

chat_response <- function(
  user_message, history = NULL,
  system_prompt = c("general", "r_code", "python_code", "sql_code"),
  api_key = Sys.getenv("OPENAI_API_SHINY"),
  model_selected = model) {

    system <- get_system_prompt(system_prompt)
    prompt <- prepare_prompt(user_message, system, history)
    chat_url <- Sys.getenv("OPENAI_COMPLETION_URL")
    body <- list(
      model = model_selected,
      messages = prompt
    )

    req <-
      resp <-
      request(chat_url) |>
      req_auth_bearer_token(token = api_key) |>
      req_headers("Content-Type" = "application/json") |>
      req_user_agent("Alexis Roldan @roldanalex | Personal Chatbot") |>
      req_body_json(body) |>
      req_retry(max_tries = 4) |>
      req_throttle(rate = 15) |>
      req_perform()

    openai_chat_response <- resp |> resp_body_json(simplifyVector = TRUE)

    openai_chat_response$choices$message$content

}

get_system_prompt <- function(system = c("general", "r_code", "python_code", "sql_code")) {

  rlang::arg_match(system)
  instructions <- switch(
    system,
    "general" = "You are an useful and resourceful assistant.",
    "r_code" = "You are a resourceful and efficient chat bot that answers questions for a R programmer.", # nolint: line_length_linter.
    "python_code" = "You are an efficient and resourceful chat bot that answers questions for a Python programmer.", # nolint: line_length_linter.
    "sql_code" = "You are an efficient and resourceful chat bot that answers questions for a SQL developer" # nolint: line_length_linter.
  )

  list(list(role = "system", content = instructions))

}

prepare_prompt <- function(user_message, system_prompt, history) {

  user_prompt <-  list(list(role = "user", content = user_message))

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