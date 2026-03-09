# Load required libraries for this file
library(bslib)

# ---- Design Tokens ----
COLOR_PRIMARY <- "#1565C0"
COLOR_PRIMARY_LIGHT <- "#1E88E5"
COLOR_ACCENT <- "#F9A825"
COLOR_SURFACE <- "#F8FAFC"
COLOR_TEXT <- "#1a1a2e"
COLOR_TEXT_SECONDARY <- "#64748B"
COLOR_ERROR <- "#dc3545"
COLOR_SUCCESS <- "#2E7D32"

# ---- Theme ----
my_theme <- bs_theme(
  bootswatch = "zephyr",
  bg = COLOR_SURFACE,
  fg = COLOR_TEXT,
  primary = COLOR_PRIMARY,
  heading_font = font_google("Space Grotesk"),
  base_font = font_collection(
    font_google("Source Sans 3"), "system-ui", "sans-serif"
  ),
  code_font = font_google("JetBrains Mono")
)

# ---- Persona Metadata ----
persona_metadata <- list(
  # Estudiantes
  list(id = "agente_primaria", name = "Agente Primaria", icon = "child", color = "#FF9800",
       category = "estudiantes",
       desc = "Educaci\u00f3n primaria peruana (6-12 a\u00f1os). Alineado al Curr\u00edculo Nacional.",
       examples = c("Ay\u00fadame con fracciones", "\u00bfQu\u00e9 es la fotos\u00edntesis?", "Ejercicios de comprensi\u00f3n lectora")),
  list(id = "pre_universitario", name = "Pre-Universitario", icon = "university", color = "#9C27B0",
       category = "estudiantes",
       desc = "Preparaci\u00f3n para admisi\u00f3n UNI, San Marcos, PUCP. Problemas paso a paso.",
       examples = c("Problema de \u00e1lgebra tipo UNI", "Estrategias para el examen", "Razonamiento verbal")),
  list(id = "ingles_titulacion", name = "Ingl\u00e9s para Titulaci\u00f3n", icon = "language", color = "#00BCD4",
       category = "estudiantes",
       desc = "Certificaci\u00f3n B1/B2 de ingl\u00e9s para titulaci\u00f3n universitaria.",
       examples = c("Practice reading comprehension", "Help me write an essay", "Explain present perfect")),
  # Negocios y Tramites
  list(id = "asistente_mype", name = "Asistente MYPE", icon = "store", color = "#4CAF50",
       category = "negocios",
       desc = "Consultor para micro y peque\u00f1as empresas peruanas. Ventas, marketing, finanzas.",
       examples = c("\u00bfC\u00f3mo mejorar mis ventas?", "Plan de marketing b\u00e1sico", "KPIs para mi negocio")),
  list(id = "tramites_peru", name = "Tr\u00e1mites Per\u00fa", icon = "file-contract", color = "#2196F3",
       category = "negocios",
       desc = "Gu\u00eda para SUNAT, RENIEC, SUNARP, municipalidades y m\u00e1s.",
       examples = c("\u00bfC\u00f3mo sacar mi RUC?", "Requisitos para licencia", "Renovar mi DNI")),
  # Programacion
  list(id = "r_code", name = "R Programmer", icon = "chart-line", color = "#673AB7",
       category = "programacion",
       desc = "Experto en R: tidyverse, ggplot2, Shiny, an\u00e1lisis estad\u00edstico.",
       examples = c("Gr\u00e1fico con ggplot2", "Limpiar datos con dplyr", "Regresi\u00f3n lineal en R")),
  list(id = "python_code", name = "Python Programmer", icon = "laptop-code", color = "#F57C00",
       category = "programacion",
       desc = "Python: data science, web, automatizaci\u00f3n, buenas pr\u00e1cticas.",
       examples = c("An\u00e1lisis con Pandas", "Web scraping b\u00e1sico", "API con FastAPI")),
  list(id = "sql_code", name = "SQL Programmer", icon = "database", color = "#607D8B",
       category = "programacion",
       desc = "SQL: consultas, optimizaci\u00f3n, dise\u00f1o de bases de datos.",
       examples = c("Consulta con JOINs", "Optimizar query lenta", "Dise\u00f1ar esquema")),
  # General
  list(id = "general", name = "Asistente General", icon = "graduation-cap", color = "#1565C0",
       category = "general",
       desc = "Tu compa\u00f1ero de aprendizaje para cualquier tema o pregunta.",
       examples = c("Expl\u00edcame la relatividad", "Ay\u00fadame con mi tarea", "\u00bfC\u00f3mo funciona la IA?")),
  list(id = "mother_assistant", name = "Asistente para Madres", icon = "heart", color = "#E91E63",
       category = "general",
       desc = "Apoyo en crianza basado en evidencia para ni\u00f1os de 0-5 a\u00f1os.",
       examples = c("Tips for sleep training", "Healthy toddler meals", "Milestones at 2 years"))
)

persona_categories <- list(
  estudiantes = list(label = "Estudiantes", icon = "book-open"),
  negocios = list(label = "Negocios y Tr\u00e1mites", icon = "briefcase"),
  programacion = list(label = "Programaci\u00f3n", icon = "code"),
  general = list(label = "General", icon = "star")
)

# Spanish-language personas (for speech recognition)
SPANISH_PERSONAS <- c("agente_primaria", "pre_universitario", "asistente_mype", "tramites_peru")

# Get persona metadata by ID
get_persona <- function(id) {
  for (p in persona_metadata) {
    if (p$id == id) return(p)
  }
  for (p in persona_metadata) {
    if (p$id == "general") return(p)
  }
}

# Get localized greeting for a persona
get_persona_greeting <- function(persona_id) {
  p <- get_persona(persona_id)
  if (persona_id %in% SPANISH_PERSONAS) {
    paste0("\u00a1Hola! Soy **MIA**, tu ", tolower(p$name),
           ". \u00bfEn qu\u00e9 te puedo ayudar hoy?\n\n",
           "*Nota: Puedo realizar b\u00fasquedas web para obtener informaci\u00f3n actualizada cuando sea necesario.*")
  } else {
    paste0("Hi! I'm **MIA**, your ", tolower(p$name),
           ". How can I help you today?\n\n",
           "*Note: I may perform web searches to fetch up-to-date information when needed.*")
  }
}

# ---- System Prompt Loading ----
get_system_prompt <- function(task) {
  if (missing(task) || is.null(task) || is.na(task) || !nzchar(task))
    task <- "general"

  markdown_dir <- file.path("markdown")

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

  markdown_file <- file_mapping[[as.character(task)]]
  if (is.null(markdown_file)) markdown_file <- "general.md"
  file_path <- file.path(markdown_dir, markdown_file)

  tryCatch({
    if (file.exists(file_path)) {
      return(readr::read_file(file_path))
    } else {
      fallback_prompts <- list(
        general = "You are MIA, a helpful AI learning assistant. Respond in a friendly, professional tone and help users learn effectively.",
        r_code = "You are MIA, an expert R programming mentor. Provide clear, well-commented R code with explanations.",
        python_code = "You are MIA, an expert Python programming mentor. Provide clean, Pythonic code with detailed explanations.",
        sql_code = "You are MIA, an expert SQL database consultant. Provide efficient, well-formatted SQL queries with explanations.",
        agente_primaria = "Eres MIA, un asistente educativo especializado en educaci\u00f3n primaria peruana.",
        pre_universitario = "Eres un tutor experto en preparaci\u00f3n pre-universitaria (UNI/San Marcos).",
        asistente_mype = "Eres un consultor de negocios para MYPEs peruanas.",
        tramites_peru = "Eres un gu\u00eda de tr\u00e1mites peruanos (SUNAT, RENIEC).",
        ingles_titulacion = "You are an English tutor for university students preparing for B1/B2 certification."
      )
      task_prompt <- fallback_prompts[[as.character(task)]]
      if (is.null(task_prompt)) task_prompt <- fallback_prompts[["general"]]
      return(task_prompt)
    }
  }, error = function(e) {
    return("You are MIA, a helpful AI assistant. Respond in a friendly, professional tone.")
  })
}

# ---- Legacy Chat Functions ----
chat_response <- function(
  user_message, history = NULL,
  system_prompt = c("general", "r_code", "python_code", "sql_code"),
  api_key = Sys.getenv("OPENAI_API_LUCY_SHINY"),
  model_selected = "gpt-4.1") {

    system <- get_system_prompt(system_prompt)
    prompt <- prepare_prompt(user_message, system, history)

    body <- list(model = model_selected, messages = prompt)

    resp <- httr2::request("https://api.openai.com/v1/chat/completions") |>
      httr2::req_headers(
        Authorization = paste("Bearer", api_key),
        `Content-Type` = "application/json"
      ) |>
      httr2::req_user_agent("Alexis Roldan @roldanalex | MIA Assistant") |>
      httr2::req_body_json(body) |>
      httr2::req_retry(max_tries = 4) |>
      httr2::req_throttle(rate = 15) |>
      httr2::req_perform()

    openai_chat_response <- resp |> httr2::resp_body_json(simplifyVector = TRUE)
    openai_chat_response$choices$message$content
}

prepare_prompt <- function(user_message, system_prompt, history) {
  user_prompt <- list(list(role = "user", content = user_message))
  c(system_prompt, history, user_prompt) |> purrr::compact()
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

# ---- File Text Extraction ----
extract_text_from_file <- function(file_path, file_name) {
  ext <- tolower(tools::file_ext(file_name))

  session <- shiny::getDefaultReactiveDomain()
  if (!is.null(session)) {
    shinyjs::html("chat_status", paste0("<span><i class='fa fa-file-alt'></i> Leyendo ", file_name, "...</span>"))
  }

  tryCatch({
    if (ext == "pdf") {
      text <- pdftools::pdf_text(file_path)
      combined_text <- paste(text, collapse = "\n")
      if (nchar(trimws(combined_text)) == 0) {
        return("[El PDF parece ser escaneado o no contiene texto extra\u00edble.]")
      }
      return(combined_text)
    } else if (ext == "docx") {
      doc <- officer::read_docx(file_path)
      content <- officer::docx_summary(doc)
      paras <- content[content$content_type == "paragraph", "text"]
      combined_text <- paste(paras, collapse = "\n")
      if (nchar(trimws(combined_text)) == 0) {
        return("[El documento Word parece estar vac\u00edo.]")
      }
      return(combined_text)
    } else if (ext %in% c("xlsx", "xls")) {
      sheets <- openxlsx::getSheetNames(file_path)
      content <- lapply(sheets, function(s) {
        df <- openxlsx::read.xlsx(file_path, sheet = s)
        csv_txt <- paste(capture.output(write.csv(df, row.names = FALSE)), collapse = "\n")
        paste0("### Sheet: ", s, "\n", csv_txt)
      })
      return(paste(content, collapse = "\n\n"))
    } else if (ext == "csv") {
      df <- readr::read_csv(file_path, show_col_types = FALSE)
      return(paste(capture.output(write.csv(df, row.names = FALSE)), collapse = "\n"))
    } else {
      return(NULL)
    }
  }, error = function(e) {
    return(paste("Error al leer", file_name, ":", e$message))
  })
}

# ---- Google Search Tool ----
perform_google_search <- function(query) {
  session <- shiny::getDefaultReactiveDomain()
  if (!is.null(session)) {
    shinyjs::html("chat_status", paste0("<span><i class='fa fa-search'></i> Buscando: '", query, "'...</span>"))
  }

  api_key <- Sys.getenv("google_search_api_key")
  cx <- Sys.getenv("google_search_engine_id")

  if (!nzchar(api_key) || !nzchar(cx)) {
    return(list(error = "Missing Google Search API key or Search Engine ID."))
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

    session <- shiny::getDefaultReactiveDomain()
    if (!is.null(session)) {
      shinyjs::html("chat_status", "<span><i class='fa fa-layer-group'></i> Procesando resultados...</span>")
    }

    return(list(results = results, retrieved_at = as.character(Sys.time())))
  }, error = function(e) {
    return(list(error = paste("Error en b\u00fasqueda:", e$message)))
  })
}

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
                   paste0(i, ") Source: ", r$title, " \u2014 ", r$link),
                   paste0("   Summary: ", r$snippet),
                   paste0("   Retrieved: ", retrieved),
                   "")
  }
  return(paste(out_lines, collapse = "\n"))
}

perform_google_search_text <- function(query, max_results = 3) {
  res <- perform_google_search(query)
  format_search_results(res, max_results = max_results)
}

tool_google_search <- ellmer::tool(
  perform_google_search_text,
  name = "perform_google_search",
  description = "Performs a Google Custom Search to retrieve up-to-date information from the web.",
  arguments = list(
    query = ellmer::type_string("The search query to send to Google."),
    max_results = ellmer::type_integer("Maximum number of results to return (optional).")
  )
)

# ---- Environment Variable Checks ----
REQUIRED_ENV_VARS <- c(
  "OPENAI_API_LUCY_SHINY",
  "google_search_api_key",
  "google_search_engine_id",
  "personal_aws_access_key",
  "personal_aws_secret_key",
  "s3ytfeedapp"
)

check_required_env_vars <- function() {
  missing <- vapply(REQUIRED_ENV_VARS, function(nm) {
    val <- Sys.getenv(nm, unset = NA)
    is.na(val) || !nzchar(val)
  }, logical(1))
  names(REQUIRED_ENV_VARS[missing])
}

missing_env_vars_message <- function() {
  miss <- check_required_env_vars()
  if (length(miss) == 0) return(NULL)
  paste0("Variables de entorno faltantes: ", paste(miss, collapse = ", "),
         ". Configura en .Renviron y reinicia la app.")
}

# ---- Password Hashing ----
BCRYPT_AVAILABLE <- requireNamespace("bcrypt", quietly = TRUE)

hash_password <- function(password) {
  if (BCRYPT_AVAILABLE) {
    bcrypt::hashpw(password)
  } else {
    password
  }
}

check_password <- function(password, stored) {
  if (BCRYPT_AVAILABLE && grepl("^\\$2[aby]\\$", stored)) {
    bcrypt::checkpw(password, stored)
  } else {
    identical(password, stored)
  }
}
