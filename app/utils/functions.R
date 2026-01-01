# Load required libraries for this file
library(bslib)

# Force light theme as default
my_theme <- bs_theme(
  bootswatch = "zephyr",
  bg = "#ffffff",
  fg = "#000000",
  primary = "#dc3545",
  heading_font = font_google("Lobster"),
  base_font = font_collection(
    font_google("Roboto Slab"), font_google("Merriweather")
  ),
  code_font = font_google("Inconsolata")
)
# my_theme <- bs_theme(
#   bg = "#e5e5e5", fg = "#0d0c0c", primary = "#dd2020",
#   base_font = font_google("Press Start 2P"),
#   code_font = font_google("Press Start 2P"),
#   "font-size-base" = "0.75rem", "enable-rounded" = FALSE
# )
  # bs_add_rules(
  #   list(
  #     sass::sass_file("nes.min.css"),
  #     sass::sass_file("custom.scss"),
  #     "body { background-color: $body-bg; }"
  #   )
  # )

get_system_prompt <- function(task) {
  # Safety: fallback prompt
  if (missing(task) || is.null(task) || is.na(task) || !nzchar(task))
    task <- "general"

  # Define the path to markdown files
  markdown_dir <- file.path("markdown")

  # Map task to markdown file
  file_mapping <- list(
    general = "general.md",
    r_code = "r_code.md",
    python_code = "python_code.md",
    sql_code = "sql_code.md",
    mother_assistant = "mother_assistant.md",
    agente_primaria = "agente_primaria.md",
    pre_universitario = "pre_universitario.md",
    asistente_mype = "asistente_mype.md",
    tramites_peru = "tramites_peru.md",
    ingles_titulacion = "ingles_titulacion.md"
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
        general = "You are MIA, a helpful AI learning assistant. Respond in a friendly, professional tone and help users learn effectively.",
        r_code = "You are MIA, an expert R programming mentor. Provide clear, well-commented R code with explanations.",
        python_code = "You are MIA, an expert Python programming mentor. Provide clean, Pythonic code with detailed explanations.",
        sql_code = "You are MIA, an expert SQL database consultant. Provide efficient, well-formatted SQL queries with explanations.",
        agente_primaria = "Eres MIA, un asistente educativo especializado en educación primaria peruana. Ayuda con todas las áreas curriculares siguiendo el Currículo Nacional del Perú.",
        pre_universitario = "Eres un tutor experto en preparación pre-universitaria (UNI/San Marcos). Explica paso a paso.",
        asistente_mype = "Eres un consultor de negocios para MYPEs peruanas. Da consejos prácticos.",
        tramites_peru = "Eres un guía de trámites peruanos (SUNAT, RENIEC). Explica los procesos claramente.",
        ingles_titulacion = "You are an English tutor for university students. Correct grammar and help with B1/B2 certification."
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
    return("You are MIA, a helpful AI assistant. Respond in a friendly, professional tone.")
  })
}

# Chat response function for OpenAI API (legacy support)
chat_response <- function(
  user_message, history = NULL,
  system_prompt = c("general", "r_code", "python_code", "sql_code"),
  api_key = Sys.getenv("OPENAI_API_LUCY_SHINY"),
  model_selected = "gpt-4.1") {

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

extract_text_from_file <- function(file_path, file_name) {
  ext <- tolower(tools::file_ext(file_name))
  
  # Update UI status
  session <- shiny::getDefaultReactiveDomain()
  if (!is.null(session)) {
    shinyjs::html("chat_status", paste0("<span><i class='fa fa-file-alt'></i> Reading ", file_name, "...</span>"))
  }

  tryCatch({
    if (ext == "pdf") {
      # Extract text from PDF
      text <- pdftools::pdf_text(file_path)
      combined_text <- paste(text, collapse = "\n")
      # Check if text is empty (e.g. scanned PDF)
      if (nchar(trimws(combined_text)) == 0) {
        return("[System Message: The PDF file appears to be scanned or contains no extractable text. Please provide a text-based PDF or summarize it manually.]")
      }
      return(combined_text)
      
    } else if (ext == "docx") {
      # Extract text from Word document
      doc <- officer::read_docx(file_path)
      content <- officer::docx_summary(doc)
      # Filter for paragraph text only
      paras <- content[content$content_type == "paragraph", "text"]
      combined_text <- paste(paras, collapse = "\n")
      if (nchar(trimws(combined_text)) == 0) {
        return("[System Message: The Word document appears to be empty.]")
      }
      return(combined_text)
      
    } else if (ext %in% c("xlsx", "xls")) {
      # Extract text from Excel sheets
      sheets <- openxlsx::getSheetNames(file_path)
      content <- lapply(sheets, function(s) {
        df <- openxlsx::read.xlsx(file_path, sheet = s)
        # Convert dataframe to CSV string for the LLM
        csv_txt <- paste(capture.output(write.csv(df, row.names = FALSE)), collapse = "\n")
        paste0("### Sheet: ", s, "\n", csv_txt)
      })
      return(paste(content, collapse = "\n\n"))
      
    } else if (ext == "csv") {
      df <- readr::read_csv(file_path, show_col_types = FALSE)
      return(paste(capture.output(write.csv(df, row.names = FALSE)), collapse = "\n"))
      
    } else {
      return(NULL) # Return NULL for images or unsupported types
    }
  }, error = function(e) {
    return(paste("Error reading file", file_name, ":", e$message))
  })
}

perform_google_search <- function(query) {
  "Performs a Google Custom Search and returns a structured result (list)."

  # Update UI status if running in Shiny
  session <- shiny::getDefaultReactiveDomain()
  if (!is.null(session)) {
    shinyjs::html("chat_status", paste0("<span><i class='fa fa-search'></i> Searching Google for: '", query, "'...</span>"))
  }

  api_key <- Sys.getenv("google_search_api_key")
  cx <- Sys.getenv("google_search_engine_id")

  if (!nzchar(api_key) || !nzchar(cx)) {
    return(list(error = "Missing Google Search API key or Search Engine ID in environment variables."))
  }

  tryCatch({
    resp <- httr2::request("https://www.googleapis.com/customsearch/v1") |>
      httr2::req_url_query(key = api_key, cx = cx, q = query) |>
      httr2::req_perform()

    data <- httr2::resp_body_json(resp)

    if (is.null(data$items) || length(data$items) == 0) {
      return(list(results = list(), retrieved_at = as.character(Sys.time())))
    }

    results <- lapply(data$items, function(item) {
      list(
        title = if (!is.null(item$title)) item$title else "",
        link  = if (!is.null(item$link)) item$link else "",
        snippet = if (!is.null(item$snippet)) item$snippet else ""
      )
    })

    # Update status to show aggregation phase
    session <- shiny::getDefaultReactiveDomain()
    if (!is.null(session)) {
      shinyjs::html("chat_status", "<span><i class='fa fa-layer-group'></i> Aggregating search results...</span>")
    }
    
    return(list(results = results, retrieved_at = as.character(Sys.time())))
  }, error = function(e) {
    return(list(error = paste("Error performing Google search:", e$message)))
  })
}


# Helper: format structured search results into a user-friendly text block
format_search_results <- function(search_res, max_results = 3) {
  if (is.null(search_res)) return("No results to format.")
  if (!is.null(search_res$error)) return(paste("Search error:", search_res$error))

  results <- search_res$results
  retrieved <- if (!is.null(search_res$retrieved_at)) search_res$retrieved_at else as.character(Sys.time())

  if (length(results) == 0) {
    return(paste0("No search results found. (retrieved: ", retrieved, ")"))
  }

  n <- min(max_results, length(results))
  out_lines <- c()
  for (i in seq_len(n)) {
    r <- results[[i]]
    out_lines <- c(out_lines,
                   paste0(i, ") Source: ", r$title, " — ", r$link),
                   paste0("   Summary: ", r$snippet),
                   paste0("   Retrieved: ", retrieved),
                   "")
  }
  return(paste(out_lines, collapse = "\n"))
}


# Text wrapper kept for compatibility and for tool registration
perform_google_search_text <- function(query, max_results = 3) {
  res <- perform_google_search(query)
  format_search_results(res, max_results = max_results)
}

tool_google_search <- ellmer::tool(
  perform_google_search_text,
  name = "perform_google_search",
  description = "Performs a Google Custom Search to retrieve up-to-date information from the web (returns title, link, snippet).",
  arguments = list(
    query = ellmer::type_string("The search query to send to Google."),
    max_results = ellmer::type_integer("Maximum number of results to format and return (optional).")
  )
)

# List of important environment variables the app may require
REQUIRED_ENV_VARS <- c(
  "OPENAI_API_LUCY_SHINY",
  "google_search_api_key",
  "google_search_engine_id",
  "personal_aws_access_key",
  "personal_aws_secret_key",
  "s3ytfeedapp"
)

# Check which required environment variables are missing (returns character vector)
check_required_env_vars <- function() {
  missing <- vapply(REQUIRED_ENV_VARS, function(nm) {
    val <- Sys.getenv(nm, unset = NA)
    is.na(val) || !nzchar(val)
  }, logical(1))
  names(REQUIRED_ENV_VARS[missing])
}

# Helper that returns a message when env vars are missing (or NULL if all present)
missing_env_vars_message <- function() {
  miss <- check_required_env_vars()
  if (length(miss) == 0) return(NULL)
  paste0("Missing required environment variables: ", paste(miss, collapse = ", "), ". Please set them in .Renviron or your shell and restart the app.")
}