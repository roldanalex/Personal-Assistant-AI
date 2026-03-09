function(input, output, session) {

  # --- STATE ---
  user_auth <- reactiveValues(logged_in = FALSE, user = NULL)
  selected_persona <- reactiveVal(NULL)
  pending_prompt <- reactiveVal(NULL)

  # ---- AUTH: LOGIN ----
  observeEvent(input$auth__login, {
    cat("Login attempt received\n")
    creds <- get_credentials()
    u <- input$auth__login$user
    p <- input$auth__login$password

    if (is.null(u) || !nzchar(u) || is.null(p) || !nzchar(p)) {
      showNotification("Ingresa usuario y contrase\u00f1a.", type = "warning")
      return()
    }

    if (u %in% creds$user) {
      stored <- creds$password[which(creds$user == u)]
      if (check_password(p, stored)) {
        cat("Login successful for user:", u, "\n")
        user_auth$logged_in <- TRUE
        user_auth$user <- u
        runjs("$('#auth-panel').removeClass('visible');")

        # Upgrade plaintext password to bcrypt if needed
        if (BCRYPT_AVAILABLE && !grepl("^\\$2[aby]\\$", stored)) {
          creds$password[which(creds$user == u)] <- hash_password(p)
          save_credentials(creds)
          cat("Password upgraded to bcrypt for user:", u, "\n")
        }
      } else {
        showNotification("Contrase\u00f1a incorrecta.", type = "error")
      }
    } else {
      showNotification("Usuario no encontrado.", type = "error")
    }
  })

  # ---- AUTH: SIGNUP ----
  observeEvent(input$auth__signup, {
    creds <- get_credentials()
    u <- input$auth__signup$user
    p <- input$auth__signup$password

    if (u %in% creds$user) {
      showNotification("El usuario ya existe.", type = "error")
    } else if (is.null(u) || is.null(p) || !nzchar(u) || !nzchar(p)) {
      showNotification("Usuario y contrase\u00f1a no pueden estar vac\u00edos.", type = "warning")
    } else if (nchar(p) < 6) {
      showNotification("La contrase\u00f1a debe tener al menos 6 caracteres.", type = "warning")
    } else {
      hashed_pw <- hash_password(p)
      new_row <- data.frame(user = u, password = hashed_pw, stringsAsFactors = FALSE)
      if (!all(c("user", "password") %in% names(creds))) {
        creds <- data.frame(user = character(0), password = character(0), stringsAsFactors = FALSE)
      }
      creds <- rbind(creds, new_row)
      save_credentials(creds)
      showNotification("\u00a1Cuenta creada! Ahora inicia sesi\u00f3n.", type = "message")
      session$sendCustomMessage(type = "resetAuthForm", message = list(form = "login"))
    }
  })

  # ---- AUTH: PASSWORD RESET ----
  observeEvent(input$auth__reset, {
    creds <- get_credentials()
    u <- input$auth__reset$user
    p <- input$auth__reset$password

    if (is.null(u) || !nzchar(u) || is.null(p) || !nzchar(p)) {
      showNotification("Completa todos los campos.", type = "warning")
      return()
    }

    if (u %in% creds$user) {
      creds$password[which(creds$user == u)] <- hash_password(p)
      save_credentials(creds)
      showNotification("Contrase\u00f1a actualizada.", type = "message")
      session$sendCustomMessage(type = "resetAuthForm", message = list(form = "login"))
    } else {
      showNotification("Usuario no encontrado.", type = "error")
    }
  })

  # ---- MAIN VIEW ROUTING ----
  output$main_view <- renderUI({
    if (!user_auth$logged_in) {
      login_ui_view()
    } else if (is.null(selected_persona())) {
      persona_selection_ui()
    } else {
      chat_ui_view(selected_persona())
    }
  })

  # ---- LOGOUT ----
  observeEvent(input$log_out, {
    user_auth$logged_in <- FALSE
    user_auth$user <- NULL
    selected_persona(NULL)
    pending_prompt(NULL)
    runjs("$('#auth-panel').addClass('visible');")
  })

  # ---- PERSONA SELECTION ----
  observeEvent(input$select_persona, {
    req(user_auth$logged_in)
    cat("Persona selected:", input$select_persona, "\n")
    selected_persona(input$select_persona)
    session$sendCustomMessage("setCurrentPersona", input$select_persona)
  })

  observeEvent(input$select_persona_with_prompt, {
    req(user_auth$logged_in)
    data <- input$select_persona_with_prompt
    cat("Persona selected with prompt:", data$persona, "-", data$prompt, "\n")
    pending_prompt(data$prompt)
    selected_persona(data$persona)
    session$sendCustomMessage("setCurrentPersona", data$persona)
  })

  # ---- CHANGE PERSONA (back to grid) ----
  observeEvent(input$change_persona, {
    req(user_auth$logged_in)
    selected_persona(NULL)
    pending_prompt(NULL)
    chat_obj(NULL)
    current_images(NULL)
    conversation_history$messages <- list()
  })

  # ---- USER DISPLAY (persona grid) ----
  output$persona_user_display <- renderUI({
    req(user_auth$logged_in)
    tags$span(
      icon("user"), " ", tags$b(user_auth$user), "  ",
      actionLink("log_out", label = tagList(icon("sign-out-alt"), "Salir"),
                 class = "logout-link")
    )
  })

  # ---- USER DISPLAY (chat view) ----
  output$current_user <- renderUI({
    req(user_auth$logged_in)
    div(
      class = "current-user-display",
      tags$span(
        icon("user"), " ",
        tags$b(user_auth$user),
        tags$span(class = "user-info-spacing",
                  actionLink("log_out", label = tagList(icon("sign-out-alt"), "Salir"),
                             class = "logout-link"))
      )
    )
  })

  # ---- ADMIN WARNING ----
  output$admin_warning <- renderUI({
    req(user_auth$logged_in)
    if (!identical(user_auth$user, "admin")) return(NULL)
    if (exists("ENV_VARS_STATUS_MSG") && !is.null(ENV_VARS_STATUS_MSG)) {
      div(class = "admin-warning alert alert-warning", role = "alert",
          tags$b("Advertencia: "), ENV_VARS_STATUS_MSG)
    }
  })

  observeEvent(user_auth$logged_in, {
    if (user_auth$logged_in && identical(user_auth$user, "admin")) {
      if (exists("ENV_VARS_STATUS_MSG") && !is.null(ENV_VARS_STATUS_MSG)) {
        showNotification(ENV_VARS_STATUS_MSG, type = "warning", duration = NULL)
      }
    }
  }, once = FALSE)

  # ---- CHATBOT STATE ----
  chat_obj <- reactiveVal(NULL)
  current_images <- reactiveVal(NULL)
  conversation_history <- reactiveValues(messages = list())

  # ---- FILE UPLOAD ----
  observeEvent(input$uploaded_image, {
    req(user_auth$logged_in, input$uploaded_image)
    cat("Files uploaded:", nrow(input$uploaded_image), "\n")

    max_size_bytes <- MAX_FILE_SIZE_MB * 1024 * 1024
    for (i in seq_len(nrow(input$uploaded_image))) {
      file_size <- file.info(input$uploaded_image$datapath[i])$size
      file_name <- input$uploaded_image$name[i]
      size_mb <- round(file_size / (1024 * 1024), 2)

      if (file_size > max_size_bytes) {
        showNotification(
          paste0("'", file_name, "' es muy grande (", size_mb, " MB). ",
                 "M\u00e1ximo: ", MAX_FILE_SIZE_MB, " MB."),
          type = "error", duration = 10
        )
        session$sendCustomMessage("resetFileInput", "uploaded_image")
        return()
      }
    }

    processed_images <- input$uploaded_image
    for (i in seq_len(nrow(processed_images))) {
      file_path <- processed_images$datapath[i]
      file_name <- processed_images$name[i]
      ext <- tolower(tools::file_ext(file_name))

      if (ext %in% c("png", "jpg", "jpeg")) {
        tryCatch({
          img <- magick::image_read(file_path)
          info <- magick::image_info(img)
          if (info$width > 1024) {
            img <- magick::image_resize(img, "1024x")
          }
          img <- magick::image_convert(img, format = "jpeg")
          temp_file <- tempfile(fileext = ".jpg")
          magick::image_write(img, temp_file, quality = 80)
          processed_images$datapath[i] <- temp_file
        }, error = function(e) {
          cat("Error processing image:", conditionMessage(e), "\n")
        })
      }
    }

    current_images(processed_images)
    later::later(function() {
      session$sendCustomMessage("clearFileInputStatus", "uploaded_image")
    }, delay = 1.5)
  })

  # ---- UPLOADED FILE PREVIEW ----
  output$show_uploaded_images <- renderUI({
    imgs <- current_images()
    if (is.null(imgs) || nrow(imgs) == 0) return(NULL)

    tagList(
      h5("Archivos adjuntos:"),
      lapply(seq_len(nrow(imgs)), function(i) {
        img_file <- imgs$datapath[i]
        file_name <- imgs$name[i]
        ext <- tolower(tools::file_ext(file_name))

        if (ext %in% c("png", "jpg", "jpeg")) {
          info <- tryCatch({
            img_info <- magick::image_info(magick::image_read(img_file))
            sprintf(" (%d x %d px)", img_info$width, img_info$height)
          }, error = function(e) "")

          filesz <- file.info(img_file)$size
          kb <- sprintf("%.1f", filesz / 1024)

          tags$div(
            style = "margin-bottom: 12px; padding: 10px; border: 1px solid #BBDEFB; border-radius: 8px; background: #E3F2FD;",
            tags$div(
              style = "font-size: 1em; color: #1565C0; margin-bottom: 4px;",
              icon("image"), " Imagen adjunta"
            ),
            tags$div(style = "font-size: 0.85em; color: #555;",
              tags$strong(file_name), tags$br(),
              paste0("Tama\u00f1o: ", kb, " KB", info)
            )
          )
        } else {
          filesz <- file.info(img_file)$size
          kb <- sprintf("%.1f", filesz / 1024)
          tags$div(
            style = "margin-bottom: 10px; padding: 8px; border: 1px solid #FFE0B2; border-radius: 8px; background: #FFF3E0;",
            icon("file-alt"), " ", tags$strong(file_name),
            tags$div(style = "font-size: 0.8em; color: #E65100;",
                     paste0("Tama\u00f1o: ", kb, " KB"))
          )
        }
      })
    )
  })

  # ---- INIT CHAT when persona is selected and model is available ----
  observeEvent(
    { list(input$model, selected_persona()) },
    {
      req(user_auth$logged_in)
      persona <- selected_persona()
      req(persona)
      model <- input$model
      if (is.null(model) || !nzchar(model)) model <- "gpt-4.1"

      cat("Initializing chat for persona:", persona, "model:", model, "\n")

      chat <- ellmer::chat_openai(
        model = model,
        system_prompt = get_system_prompt(persona)
      )
      chat$register_tool(tool_google_search)
      chat_obj(chat)

      chat_clear("chat")
      greeting <- get_persona_greeting(persona)

      shinyjs::delay(250, {
        chat_append("chat", list(
          list(role = " ", content = greeting)
        ))

        # If there's a pending prompt from example chip click, send it
        prompt <- isolate(pending_prompt())
        if (!is.null(prompt) && nzchar(prompt)) {
          pending_prompt(NULL)
          shinyjs::delay(500, {
            # Set the chat input and trigger submission
            runjs(sprintf("
              var $input = $('#main-content-panel textarea').first();
              if ($input.length) {
                $input.val('%s');
                $input[0].dispatchEvent(new Event('input', { bubbles: true }));
                setTimeout(function() {
                  var $form = $input.closest('form');
                  if ($form.length) $form.trigger('submit');
                  else {
                    var e = new KeyboardEvent('keydown', {key: 'Enter', bubbles: true});
                    $input[0].dispatchEvent(e);
                  }
                }, 200);
              }
            ", gsub("'", "\\\\'", prompt)))
          })
        }
      })

      current_images(NULL)
      session$sendCustomMessage("resetFileInput", "uploaded_image")
      conversation_history$messages <- list()
    }
  )

  # ---- CHAT SUBMISSION ----
  observeEvent(input$chat_user_input, {
    req(user_auth$logged_in)
    req(nzchar(input$chat_user_input))
    req(chat_obj())

    shinyjs::disable("download_chat")

    imgs <- current_images()
    shinyjs::html("chat_status", "")

    # Append user message with images if present
    if (!is.null(imgs) && nrow(imgs) > 0) {
      showNotification("Analizando archivos adjuntos...", duration = 3, type = "message")
      shinyjs::html("chat_status", as.character(tags$span(icon("layer-group"), " Procesando adjuntos...")))

      user_content_elements <- list()
      encoded_images <- list()

      file_blocks <- lapply(seq_len(nrow(imgs)), function(i) {
        img_file <- imgs$datapath[i]
        file_name <- imgs$name[i]
        ext <- tolower(tools::file_ext(file_name))

        if (ext %in% c("png", "jpg", "jpeg")) {
          data_uri <- base64enc::dataURI(
            file = img_file,
            mime = switch(ext, png = "image/png", jpg = "image/jpeg",
                         jpeg = "image/jpeg", "image/png")
          )
          encoded_images[[i]] <<- data_uri

          info <- tryCatch({
            dims <- NULL
            if (ext == "png") dims <- dim(png::readPNG(img_file))
            else dims <- dim(jpeg::readJPEG(img_file))
            if (!is.null(dims)) paste0(dims[2], "x", dims[1], "px") else ""
          }, error = function(e) "")

          filesz <- file.info(img_file)$size
          kb <- sprintf("%.1f", filesz / 1024)

          tags$div(
            tags$img(src = data_uri, class = "image-preview-small"),
            tags$p(class = "image-info-text",
              sprintf("%s (%s KB)%s", file_name, kb,
                      if (nzchar(info)) paste0(" \u2022 ", info) else ""))
          )
        } else {
          tags$div(
            class = "doc-attachment",
            style = "margin-bottom: 8px; padding: 5px; border-left: 3px solid #1565C0; background-color: rgba(21, 101, 192, 0.08);",
            icon("file-alt"), " ", tags$span(file_name, style = "font-weight:bold;")
          )
        }
      })
      user_content_elements <- c(user_content_elements, file_blocks)
      user_content_elements <- c(user_content_elements, list(
        tags$div(class = "user-message-spacing", input$chat_user_input)
      ))

      chat_append("chat", list(list(
        role = "user",
        content = tagList(user_content_elements)
      )))
    }

    # Build args for LLM
    args <- list()
    if (!is.null(imgs) && nrow(imgs) > 0) {
      for (i in seq_len(nrow(imgs))) {
        fpath <- imgs$datapath[i]
        fname <- imgs$name[i]
        ext <- tolower(tools::file_ext(fname))

        if (ext %in% c("png", "jpg", "jpeg")) {
          args <- c(args, list(ellmer::content_image_file(fpath)))
        } else {
          extracted_text <- extract_text_from_file(fpath, fname)
          if (!is.null(extracted_text)) {
            context_str <- paste0("\n\n--- ARCHIVO ADJUNTO: ", fname, " ---\n",
                                 extracted_text, "\n--- FIN ARCHIVO ---\n\n")
            args <- c(args, list(context_str))
          }
        }
      }
    }
    args <- c(args, input$chat_user_input)

    # Store in conversation history
    user_message_content <- input$chat_user_input
    if (!is.null(imgs) && nrow(imgs) > 0) {
      images_html <- ""
      for (i in seq_len(nrow(imgs))) {
        fpath <- imgs$datapath[i]
        fname <- imgs$name[i]
        ext <- tolower(tools::file_ext(fname))
        if (ext %in% c("png", "jpg", "jpeg")) {
          data_uri <- base64enc::dataURI(
            file = fpath,
            mime = switch(ext, png = "image/png", jpg = "image/jpeg",
                         jpeg = "image/jpeg", "image/jpeg")
          )
          images_html <- paste0(images_html,
            "<img src='", data_uri,
            "' style='max-width: 100%; border-radius: 8px; margin: 10px 0;' alt='",
            fname, "' /><br>\n")
        }
      }
      user_message_content <- paste0(images_html, "<p>", user_message_content, "</p>")
    }

    conversation_history$messages <- append(
      conversation_history$messages,
      list(list(role = "user", content = user_message_content))
    )

    # Trim history
    if (length(conversation_history$messages) > MAX_CONVERSATION_HISTORY) {
      start_idx <- length(conversation_history$messages) - MAX_CONVERSATION_HISTORY + 1
      conversation_history$messages <- conversation_history$messages[start_idx:length(conversation_history$messages)]
    }

    # Update message counter
    msg_count <- length(conversation_history$messages)
    session$sendCustomMessage("updateMessageCounter",
      list(count = msg_count, max = MAX_CONVERSATION_HISTORY))

    shinyjs::html("chat_status", as.character(tags$span(icon("brain"), " Generando respuesta...")))

    # Stream response
    current_response <- ""

    wrapped_stream <- coro::async_generator(function() {
      stream <- do.call(chat_obj()$stream_async, args)
      repeat {
        chunk <- NULL
        had_error <- FALSE
        tryCatch({
          chunk <- stream()
        }, error = function(e) {
          if (!inherits(e, "coro_iterator_break")) {
            chunk <<- paste0("\u26a0\ufe0f Error: ", conditionMessage(e))
            had_error <<- TRUE
          }
        })

        if (is.null(chunk)) break

        if (inherits(chunk, "promise")) {
          chunk_text <- coro::await(chunk)
        } else {
          chunk_text <- as.character(chunk)
        }

        current_response <<- paste0(current_response, chunk_text)
        coro::yield(chunk)

        if (had_error) break
      }
      cat("Stream complete. Response length:", nchar(current_response), "\n")
    })

    chat_append("chat", wrapped_stream())

    # Save response after stream completes
    current_session <- session
    later::later(function() {
      if (nchar(current_response) > 0) {
        isolate({
          conversation_history$messages <- append(
            conversation_history$messages,
            list(list(role = "assistant", content = current_response))
          )

          if (length(conversation_history$messages) > MAX_CONVERSATION_HISTORY) {
            start_idx <- length(conversation_history$messages) - MAX_CONVERSATION_HISTORY + 1
            conversation_history$messages <- conversation_history$messages[start_idx:length(conversation_history$messages)]
          }

          # Update counter after assistant response
          msg_count <- length(conversation_history$messages)
          current_session$sendCustomMessage("updateMessageCounter",
            list(count = msg_count, max = MAX_CONVERSATION_HISTORY))
        })
      }

      current_session$sendCustomMessage("clearChatStatus", list())
      current_session$sendCustomMessage("enableDownloadButton", list())
    }, delay = 40)
  })

  # ---- NEW CHAT ----
  observeEvent(input$new_chat, {
    req(user_auth$logged_in)
    persona <- selected_persona()
    req(persona)
    model <- input$model
    if (is.null(model) || !nzchar(model)) model <- "gpt-4.1"

    cat("New chat - resetting\n")

    chat_clear("chat")
    chat <- ellmer::chat_openai(
      model = model,
      system_prompt = get_system_prompt(persona)
    )
    chat$register_tool(tool_google_search)
    chat_obj(chat)

    greeting <- get_persona_greeting(persona)
    chat_append("chat", list(list(role = " ", content = greeting)))

    shinyjs::enable("download_chat")
    current_images(NULL)
    conversation_history$messages <- list()
    session$sendCustomMessage("resetFileInput", "uploaded_image")
    session$sendCustomMessage("updateMessageCounter", list(count = 0, max = MAX_CONVERSATION_HISTORY))
    Sys.sleep(0.1)
    session$sendCustomMessage("resetFileInput", "uploaded_image")
  })

  # ---- DOWNLOAD CHAT HISTORY ----
  output$download_chat <- downloadHandler(
    filename = function() {
      paste("mia-chat-", format(Sys.time(), "%Y%m%d-%H%M"), ".html", sep = "")
    },
    content = function(file) {
      tryCatch({
        Sys.sleep(0.5)
        messages <- isolate(conversation_history$messages)

        if (length(messages) == 0) {
          writeLines(paste0(
            "<!DOCTYPE html><html><head><meta charset='utf-8'><title>MIA - Historial</title></head><body>",
            "<div style='text-align: center; margin-top: 100px; font-family: system-ui;'>",
            "<h1 style='color: #1565C0;'>MIA - Historial de Chat</h1>",
            "<p style='color: #666;'>No hay mensajes a\u00fan. Inicia una conversaci\u00f3n.</p>",
            "<p style='color: #999; font-size: 0.9em;'>Exportado el ", format(Sys.time(), "%d/%m/%Y a las %H:%M"), "</p>",
            "</div></body></html>"
          ), file)
          return()
        }

        html_header <- paste0(
          "<!DOCTYPE html>\n<html><head>\n<meta charset='utf-8'>\n",
          "<meta name='viewport' content='width=device-width, initial-scale=1'>\n",
          "<title>MIA - Historial de Chat</title>\n",
          "<style>\n",
          "body { font-family: 'Source Sans 3', -apple-system, system-ui, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; background-color: #F8FAFC; color: #1a1a2e; }\n",
          ".chat-container { display: flex; flex-direction: column; gap: 15px; }\n",
          ".message { padding: 15px; border-radius: 12px; max-width: 85%; line-height: 1.5; box-shadow: 0 1px 2px rgba(0,0,0,0.08); }\n",
          ".user { align-self: flex-end; background-color: #1565C0; color: white; border-bottom-right-radius: 2px; }\n",
          ".assistant { align-self: flex-start; background-color: #ffffff; border-bottom-left-radius: 2px; border: 1px solid #E2E8F0; }\n",
          ".role-label { font-size: 0.8em; margin-bottom: 5px; opacity: 0.8; font-weight: bold; }\n",
          "img { max-width: 100%; border-radius: 8px; margin-top: 10px; }\n",
          "pre { background: rgba(0,0,0,0.05); padding: 10px; border-radius: 5px; overflow-x: auto; white-space: pre-wrap; }\n",
          ".user pre { background: rgba(255,255,255,0.1); }\n",
          "code { background: rgba(0,0,0,0.05); padding: 2px 5px; border-radius: 3px; font-family: 'JetBrains Mono', monospace; }\n",
          "</style>\n</head><body>\n",
          "<div style='text-align: center; margin-bottom: 30px;'>\n",
          "<h1 style='color: #1565C0; font-family: Space Grotesk, system-ui;'>MIA - Historial de Chat</h1>\n",
          "<p>Exportado el ", format(Sys.time(), "%d/%m/%Y a las %H:%M"), "</p>\n",
          "</div>\n<div class='chat-container'>\n"
        )

        messages_html <- c()
        for (i in seq_along(messages)) {
          tryCatch({
            msg <- messages[[i]]
            role <- msg$role
            content <- msg$content

            if (is.null(role) || role == "system") next

            role_cls <- if (role == "user") "user" else "assistant"
            role_name <- if (role == "user") "T\u00fa" else "MIA"

            content_html <- ""
            if (is.character(content) && length(content) > 0 && nzchar(trimws(content))) {
              content_html <- tryCatch({
                as.character(markdown::mark(text = content))
              }, error = function(e) {
                paste0("<p>", gsub("<", "&lt;", gsub(">", "&gt;", content)), "</p>")
              })
            }

            if (nzchar(content_html)) {
              msg_html <- paste0(
                "<div class='message ", role_cls, "'>\n",
                "<div class='role-label'>", role_name, "</div>\n",
                content_html, "\n</div>\n"
              )
              messages_html <- c(messages_html, msg_html)
            }
          }, error = function(e) {
            cat("Error processing message", i, ":", e$message, "\n")
          })
        }

        html_footer <- "</div>\n</body></html>"
        complete_html <- paste0(html_header, paste(messages_html, collapse = ""), html_footer)
        writeLines(complete_html, file, useBytes = FALSE)

      }, error = function(e) {
        cat("Error in download:", e$message, "\n")
        error_msg <- gsub("<", "&lt;", gsub(">", "&gt;", e$message))
        writeLines(paste0(
          "<!DOCTYPE html><html><head><meta charset='utf-8'></head><body>",
          "<h1>Error</h1><p>", error_msg, "</p></body></html>"
        ), file)
      })
    }
  )
}
