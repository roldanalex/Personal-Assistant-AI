function(input, output, session) {

  # --- AUTH STATE ---
  user_auth <- reactiveValues(logged_in = FALSE, user = NULL)

  # LOGIN Handler
  observeEvent(input$auth__login, {
    cat("Login attempt received\n")
    creds <- get_credentials()
    u <- input$auth__login$user
    p <- input$auth__login$password
    cat("Username:", u, "Password length:", nchar(p), "\n")

    if (u %in% creds$user) {
      stored <- creds$password[which(creds$user == u)]
      if (identical(stored, p)) {
        cat("Login successful for user:", u, "\n")
        user_auth$logged_in <- TRUE
        user_auth$user <- u
        # Hide auth panel on successful login
        runjs("$('#auth-panel').removeClass('visible');")
      } else {
        cat("Incorrect password for user:", u, "\n")
        showNotification("Incorrect password.", type = "error")
      }
    } else {
      cat("Username not found:", u, "\n")
      showNotification("Username not found.", type = "error")
    }
  })

  # SIGNUP Handler
  observeEvent(input$auth__signup, {
    creds <- get_credentials()
    u <- input$auth__signup$user
    p <- input$auth__signup$password

    if (u %in% creds$user) {
      showNotification("Username already exists.", type = "error")
    } else if (is.na(u) || is.na(p) || !nzchar(u) || !nzchar(p)) {
      showNotification("Username and password must not be empty", type = "warning")
    } else {
      new_row <- data.frame(user = u, password = p, stringsAsFactors = FALSE)
      # Defensive: Ensure columns match
      if (!all(c("user", "password") %in% names(creds))) {
        creds <- data.frame(user = character(0), password = character(0), stringsAsFactors = FALSE)
      }
      creds <- rbind(creds, new_row)
      save_credentials(creds)
      showNotification("Signup success! Please login.", type = "message")
      session$sendCustomMessage(type="resetAuthForm", message=list(form="login"))
    }
  })

  # PASSWORD RESET Handler
  observeEvent(input$auth__reset, {
    creds <- get_credentials()
    u <- input$auth__reset$user
    p <- input$auth__reset$password

    if (u %in% creds$user) {
      creds$password[which(creds$user == u)] <- p
      save_credentials(creds)
      showNotification("Password reset successful", type = "message")
      session$sendCustomMessage(type="resetAuthForm", message=list(form="login"))
    } else {
      showNotification("Username not found.", type = "error")
    }
  })

  # Render Main UI based on login state
  output$main_view <- renderUI({
    if (user_auth$logged_in) {
      # User is logged in, hide auth panel and show chat
      runjs("$('#auth-panel').removeClass('visible');")
      chat_ui_view()
    } else {
      # Show auth panel when not logged in
      runjs("$('#auth-panel').addClass('visible');")
      login_ui_view()
    }
  })

  # LOGOUT
  observeEvent(input$log_out, {
    user_auth$logged_in <- FALSE
    user_auth$user <- NULL
    # Show auth panel again
    runjs("$('#auth-panel').addClass('visible');")
  })

  output$current_user <- renderUI({
    req(user_auth$logged_in)
    div(
      class = "current-user-display",
      tags$span(
        icon("user"), " ",
        tags$b(user_auth$user),
        tags$span(class = "user-info-spacing",
                  actionLink("log_out", label = tagList(icon("sign-out-alt"), "Logout"),
                             class = "logout-link"))
      )
    )
  })

  # Admin warning UI: show when environment variables are missing
  output$admin_warning <- renderUI({
    req(user_auth$logged_in)
    # Only show to admin user
    if (!identical(user_auth$user, "admin")) return(NULL)
    if (exists("ENV_VARS_STATUS_MSG") && !is.null(ENV_VARS_STATUS_MSG)) {
      div(class = "admin-warning alert alert-warning", role = "alert",
          tags$b("Configuration Warning: "), ENV_VARS_STATUS_MSG)
    } else {
      NULL
    }
  })

  # Notify admin on successful login if env vars are missing
  observeEvent(user_auth$logged_in, {
    if (user_auth$logged_in && identical(user_auth$user, "admin")) {
      if (exists("ENV_VARS_STATUS_MSG") && !is.null(ENV_VARS_STATUS_MSG)) {
        showNotification(ENV_VARS_STATUS_MSG, type = "warning", duration = NULL)
      }
    }
  }, once = FALSE)

  # ---- CHATBOT FUNCTIONALITY ----

  chat_obj <- reactiveVal()
  current_images <- reactiveVal(NULL)
  conversation_history <- reactiveValues(messages = list())

  observeEvent(input$uploaded_image, {
    req(user_auth$logged_in, input$uploaded_image)
    cat("Image uploaded. Files:", nrow(input$uploaded_image), "\n")
    
    # MEMORY OPTIMIZATION: Validate file sizes before processing
    max_size_bytes <- MAX_FILE_SIZE_MB * 1024 * 1024
    for (i in seq_len(nrow(input$uploaded_image))) {
      file_size <- file.info(input$uploaded_image$datapath[i])$size
      file_name <- input$uploaded_image$name[i]
      size_mb <- round(file_size / (1024 * 1024), 2)
      
      if (file_size > max_size_bytes) {
        showNotification(
          paste0("File '", file_name, "' is too large (", size_mb, " MB). ",
                 "Maximum allowed size is ", MAX_FILE_SIZE_MB, " MB. ",
                 "Please compress or resize the file before uploading."),
          type = "error",
          duration = 10
        )
        # Reset file input
        session$sendCustomMessage("resetFileInput", "uploaded_image")
        return()
      }
    }
    
    # Process and optimize images immediately to reduce memory usage
    processed_images <- input$uploaded_image
    
    for (i in seq_len(nrow(processed_images))) {
      file_path <- processed_images$datapath[i]
      file_name <- processed_images$name[i]
      ext <- tolower(tools::file_ext(file_name))
      
      # Only resize/compress image files (not PDFs, documents, etc.)
      if (ext %in% c("png", "jpg", "jpeg")) {
        tryCatch({
          # Read image
          img <- magick::image_read(file_path)
          
          # Get original dimensions
          info <- magick::image_info(img)
          orig_width <- info$width
          orig_height <- info$height
          
          cat("Original image size:", orig_width, "x", orig_height, "\n")
          
          # Resize if width > 1024px (maintains aspect ratio)
          if (orig_width > 1024) {
            img <- magick::image_resize(img, "1024x")
            cat("Resized to 1024px width\n")
          }
          
          # Convert to JPEG format for compression
          # (PNG and JPEG both become JPEG to reduce size)
          img <- magick::image_convert(img, format = "jpeg")
          
          # Create temp file for optimized image with 80% quality
          temp_file <- tempfile(fileext = ".jpg")
          magick::image_write(img, temp_file, quality = 80)
          
          # Update the datapath to point to optimized image
          processed_images$datapath[i] <- temp_file
          
          # Update size info
          new_size <- file.info(temp_file)$size
          orig_size <- file.info(file_path)$size
          cat("Compressed from", round(orig_size/1024, 1), "KB to", 
              round(new_size/1024, 1), "KB\n")
          
        }, error = function(e) {
          cat("Error processing image:", conditionMessage(e), "\n")
          # Keep original if processing fails
        })
      }
    }
    
    # Store the processed/optimized uploaded_image data
    current_images(processed_images)
    
    # For mobile camera captures, we need a longer delay before clearing status
    # Use later::later() instead of Sys.sleep() to avoid blocking reactive context
    later::later(function() {
      session$sendCustomMessage("clearFileInputStatus", "uploaded_image")
    }, delay = 1.5)
  })

  output$show_uploaded_images <- renderUI({
    # Use current_images reactive value as the source of truth
    imgs <- current_images()

    cat("Rendering image preview. Images:", ifelse(is.null(imgs), "NULL", nrow(imgs)), "\n")

    # If current_images is NULL (reset), don't show anything
    if (is.null(imgs) || nrow(imgs) == 0) {
      return(NULL)
    }

    tagList(
      h5("Attached files:"),
      lapply(seq_len(nrow(imgs)), function(i) {
        img_file <- imgs$datapath[i]
        file_name <- imgs$name[i]
        ext <- tolower(tools::file_ext(file_name))
        
        if (ext %in% c("png", "jpg", "jpeg")) {
        # MEMORY OPTIMIZATION: Commented out base64 preview to reduce memory usage
        # The small preview wasn't very useful anyway, and it was creating additional
        # base64 encodings that consumed memory. Now just showing file info.
        
        # data_uri <- base64enc::dataURI(
        #   file = img_file,
        #   mime = switch(
        #     ext,
        #     png  = "image/png",
        #     jpg  = "image/jpeg",
        #     jpeg = "image/jpeg",
        #     "image/png"
        #   )
        # )
        # tags$img(
        #   src = data_uri,
        #   class = "image-preview-large"
        # )
        
        # Get image dimension info
        info <- tryCatch({
          img_info <- magick::image_info(magick::image_read(img_file))
          sprintf(" (%d x %d px)", img_info$width, img_info$height)
        }, error = function(e) "")

        # Get file size
        filesz <- file.info(img_file)$size
        kb <- sprintf("%.1f", filesz / 1024)

        tags$div(
          style = "margin-bottom: 15px; padding: 10px; border: 1px solid #ddd; border-radius: 5px; background: #e3f2fd;",
          tags$div(
            style = "font-size: 1.1em; color: #1976d2; margin-bottom: 5px;",
            icon("image"), " Image attached"
          ),
          tags$div(style = "font-size: 0.85em; color: #555;",
            tags$strong(file_name), tags$br(),
            paste0("Size: ", kb, " KB", info)
          )
        )
        } else {
          # Document preview
          filesz <- file.info(img_file)$size
          kb <- sprintf("%.1f", filesz / 1024)
          tags$div(
            class = "file-preview-item",
            style = "margin-bottom: 10px; padding: 8px; border: 1px solid #ddd; border-radius: 5px; background: #fff3cd;",
            tags$div(icon("file-alt"), " ", tags$strong(file_name)),
            tags$div(style = "font-size: 0.8em; color: #856404;", paste0("Size: ", kb, " KB"))
          )
        }
      })
    )
  })

  # Update chat when model or task changes (after login)
  observeEvent(
    { list(input$model, input$task) },
    {
      req(user_auth$logged_in)
      req(input$model, input$task)

      chat <- ellmer::chat_openai(
        model = input$model,
        system_prompt = get_system_prompt(input$task)
      )
      chat$register_tool(tool_google_search)
      chat_obj(chat)

      chat_clear("chat")
      # Add delay to ensure UI is fully rendered before appending greeting
      shinyjs::delay(250, {
        chat_append("chat", list(
          list(
            role = " ",
            content = "Hi, I'm MIA, your personal AI assistant. How can I help you today?\n\nNote: I may perform controlled web searches to fetch up-to-date information when needed; results include title, link, and short snippet."
          )
        ))
      })
      current_images(NULL)
      session$sendCustomMessage("resetFileInput", "uploaded_image")
    }
  ) # Removed ignoreInit=TRUE so this runs once when UI loads

  # CHAT SUBMISSION: Only send when everything is truly ready
  observeEvent(input$chat_user_input, {
    req(user_auth$logged_in)
    req(nzchar(input$chat_user_input))
    req(chat_obj())    # ensure chat is initialized

    # Disable download button to prevent incomplete downloads
    shinyjs::disable("download_chat")

    # Use current_images as the source of truth
    imgs <- current_images()
    
    # Reset status
    shinyjs::html("chat_status", "")

    # Only manually append user message if there are images
    # shinychat handles text-only messages automatically
    if (!is.null(imgs) && nrow(imgs) > 0) {
      # Show notification while processing files
      showNotification("Analyzing attached files...", duration = 3, type = "message")
      shinyjs::html("chat_status", as.character(tags$span(icon("layer-group"), " Processing attachments...")))

      # Prepare user message content with images and text
      user_content_elements <- list()
      
      # MEMORY OPTIMIZATION: Pre-encode images once and store for reuse
      # This prevents multiple base64 encodings of the same image
      encoded_images <- list()

      # Add files (images or docs)
      file_blocks <- lapply(seq_len(nrow(imgs)), function(i) {
        img_file <- imgs$datapath[i]
        file_name <- imgs$name[i]
        ext <- tolower(tools::file_ext(file_name))
        
        if (ext %in% c("png", "jpg", "jpeg")) {
          # Image handling - SINGLE BASE64 ENCODING
          # Create base64 encoding once and store it
        data_uri <- base64enc::dataURI(
          file = img_file,
          mime = switch(
            ext,
            png  = "image/png",
            jpg  = "image/jpeg",
            jpeg = "image/jpeg",
            "image/png"
          )
        )
        # Store for potential reuse (currently only using once, but infrastructure is ready)
        encoded_images[[i]] <<- data_uri
        
        # Get image dimension info
        info <- tryCatch({
          dims <- NULL
          if (ext %in% c("png")) {
            dims <- dim(png::readPNG(img_file))
          } else if (ext %in% c("jpg", "jpeg")) {
            dims <- dim(jpeg::readJPEG(img_file))
          }
          if (!is.null(dims)) {
            width <- dims[2]
            height <- dims[1]
            paste0(width, "x", height, "px")
          } else {
            ""
          }
        }, error = function(e) "")

        # Fallback on file size
        filesz <- file.info(img_file)$size
        kb <- sprintf("%.1f", filesz / 1024)

        tags$div(
          tags$img(
            src = data_uri,
            class = "image-preview-small"
          ),
          tags$p(
            class = "image-info-text",
              sprintf("%s (%s KB)%s", file_name, kb, if (nzchar(info)) paste0(" • ", info) else "")
          )
        )
        } else {
          # Document handling
          tags$div(
            class = "doc-attachment",
            style = "margin-bottom: 8px; padding: 5px; border-left: 3px solid #2E86AB; background-color: rgba(46, 134, 171, 0.1);",
            icon("file-alt"), " ", tags$span(file_name, style="font-weight:bold;")
          )
        }
      })
      user_content_elements <- c(user_content_elements, file_blocks)

      # Add text content
      user_content_elements <- c(user_content_elements, list(
        tags$div(class = "user-message-spacing", input$chat_user_input)
      ))

      # Create complete user message with images and text combined
      chat_append("chat", list(list(
        role = "user",
        content = tagList(user_content_elements)
      )))
    }

    # Compose ellmer chat message for AI response
    args <- list()
    if (!is.null(imgs) && nrow(imgs) > 0) {
      cat("Processing", nrow(imgs), "files for LLM\n")
      
      for (i in seq_len(nrow(imgs))) {
        fpath <- imgs$datapath[i]
        fname <- imgs$name[i]
        ext <- tolower(tools::file_ext(fname))
        
        if (ext %in% c("png", "jpg", "jpeg")) {
          # It's an image
          args <- c(args, list(ellmer::content_image_file(fpath)))
        } else {
          # It's a document - extract text
          extracted_text <- extract_text_from_file(fpath, fname)
          if (!is.null(extracted_text)) {
            context_str <- paste0("\n\n--- ATTACHED FILE: ", fname, " ---\n", extracted_text, "\n--- END FILE ---\n\n")
            args <- c(args, list(context_str))
          }
        }
      }
    } else {
      cat("No files to send to LLM\n")
    }
    args <- c(args, input$chat_user_input)

    # Store user message in conversation history (include images if present)
    user_message_content <- input$chat_user_input
    
    # If there are images, prepend them to the message content as HTML
    if (!is.null(imgs) && nrow(imgs) > 0) {
      images_html <- ""
      for (i in seq_len(nrow(imgs))) {
        fpath <- imgs$datapath[i]
        fname <- imgs$name[i]
        ext <- tolower(tools::file_ext(fname))
        
        if (ext %in% c("png", "jpg", "jpeg")) {
          # Create base64 data URI for the image
          data_uri <- base64enc::dataURI(
            file = fpath,
            mime = switch(
              ext,
              png  = "image/png",
              jpg  = "image/jpeg",
              jpeg = "image/jpeg",
              "image/jpeg"
            )
          )
          images_html <- paste0(images_html, 
                               "<img src='", data_uri, "' style='max-width: 100%; border-radius: 8px; margin: 10px 0;' alt='", fname, "' /><br>\n")
        }
      }
      # Prepend images to message content
      user_message_content <- paste0(images_html, "<p>", user_message_content, "</p>")
    }
    
    conversation_history$messages <- append(
      conversation_history$messages,
      list(list(role = "user", content = user_message_content))
    )
    
    # MEMORY OPTIMIZATION: Limit conversation history to prevent memory bloat
    # Keep only the most recent messages
    if (length(conversation_history$messages) > MAX_CONVERSATION_HISTORY) {
      # Keep last MAX_CONVERSATION_HISTORY messages
      start_idx <- length(conversation_history$messages) - MAX_CONVERSATION_HISTORY + 1
      conversation_history$messages <- conversation_history$messages[start_idx:length(conversation_history$messages)]
      cat("Conversation history trimmed to", MAX_CONVERSATION_HISTORY, "messages\n")
    }
    
    # Update status for thinking phase
    shinyjs::html("chat_status", as.character(tags$span(icon("brain"), " Generating response...")))

    # Send to AI and get response stream
    # Accumulate response for history
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
            chunk <<- paste0("⚠️ Error: ", conditionMessage(e))
            had_error <<- TRUE
          }
        })
        
        if (is.null(chunk)) break
        
        # Await promises if needed
        if (inherits(chunk, "promise")) {
          chunk_text <- coro::await(chunk)
        } else {
          chunk_text <- as.character(chunk)
        }
        
        current_response <<- paste0(current_response, chunk_text)
        coro::yield(chunk)
        
        if (had_error) break
      }
      
      # --- STREAM COMPLETED ---
      cat("Stream complete. Response length:", nchar(current_response), "\n")
    })
    
    chat_append("chat", wrapped_stream())
    
    # Save assistant response to history after stream completes
    # Use later::later for one-time execution (40 seconds to ensure full response captured)
    current_session <- session
    later::later(function() {
      cat("Stream processing complete - saving response\n")
      
      # Save assistant response to history (only once)
      if (nchar(current_response) > 0) {
        cat("Saving assistant response to history. Length:", nchar(current_response), "\n")
        
        # Use isolate() to access reactive values outside reactive context
        isolate({
          # Append to conversation history
          conversation_history$messages <- append(
            conversation_history$messages,
            list(list(role = "assistant", content = current_response))
          )
          
          # MEMORY OPTIMIZATION: Limit conversation history to prevent memory bloat
          if (length(conversation_history$messages) > MAX_CONVERSATION_HISTORY) {
            start_idx <- length(conversation_history$messages) - MAX_CONVERSATION_HISTORY + 1
            conversation_history$messages <- conversation_history$messages[start_idx:length(conversation_history$messages)]
            cat("Conversation history trimmed to", MAX_CONVERSATION_HISTORY, "messages\n")
          }
          
          cat("Assistant response saved. Total messages:", length(conversation_history$messages), "\n")
        })
      }
      
      # Clear status and enable download
      cat("Clearing status and enabling download\n")
      current_session$sendCustomMessage("clearChatStatus", list())
      current_session$sendCustomMessage("enableDownloadButton", list())
    }, delay = 40)
    
    # DON'T reset images after sending - keep them until new chat
    # Images should persist so user can ask follow-up questions about them
    cat("Images retained for follow-up questions\n")
  })

  # NEW CHAT BUTTON
  observeEvent(input$new_chat, {
    req(user_auth$logged_in)
    req(input$model, input$task)
    cat("New chat button clicked - resetting everything\n")

    chat_clear("chat")
    chat <- ellmer::chat_openai(
      model = input$model,
      system_prompt = get_system_prompt(input$task)
    )
    chat$register_tool(tool_google_search)
    chat_obj(chat)

    chat_append("chat", list(
      list(
        role = " ",
        content = "Hi, I'm MIA, your personal AI assistant. How can I help you today?\n\nNote: I may perform controlled web searches to fetch up-to-date information when needed; results include title, link, and short snippet."
      )
    ))
    # Reset images and conversation history when starting new chat
    cat("Clearing images and conversation history for new chat\n")
    shinyjs::enable("download_chat")
    current_images(NULL)
    conversation_history$messages <- list()
    session$sendCustomMessage("resetFileInput", "uploaded_image")
    # Additional reset to ensure complete cleanup
    Sys.sleep(0.1)
    session$sendCustomMessage("resetFileInput", "uploaded_image")
  })

  # DOWNLOAD CHAT HISTORY
  output$download_chat <- downloadHandler(
    filename = function() {
      paste("mia-chat-history-", format(Sys.time(), "%Y%m%d-%H%M"), ".html", sep = "")
    },
    content = function(file) {
      tryCatch({
        cat("Starting download handler...\n")
        
        # Add small delay to ensure history is fully updated
        Sys.sleep(0.5)
        
        # Get conversation history from manually tracked messages
        messages <- isolate(conversation_history$messages)
        cat("Number of messages in history:", length(messages), "\n")
        
        # Debug: print all messages
        for (i in seq_along(messages)) {
          msg <- messages[[i]]
          cat("Message", i, "- Role:", msg$role, "Content length:", nchar(msg$content), "\n")
        }
        
        # If no messages yet, just create a simple message
        if (length(messages) == 0) {
          cat("No conversation history yet - creating info page\n")
          writeLines(paste0(
            "<!DOCTYPE html><html><head><meta charset='utf-8'><title>MIA Chat History</title></head><body>",
            "<div style='text-align: center; margin-top: 100px; font-family: system-ui;'>",
            "<h1>🤖 MIA Chat History</h1>",
            "<p style='color: #666;'>No messages yet. Start a conversation and try again!</p>",
            "<p style='color: #999; font-size: 0.9em;'>Exported on ", format(Sys.time(), "%B %d, %Y at %H:%M"), "</p>",
            "</div></body></html>"
          ), file)
          return()
        }
        
        # HTML Header & CSS
        html_header <- paste0(
          "<!DOCTYPE html>\n",
          "<html><head>\n",
          "<meta charset='utf-8'>\n",
          "<meta name='viewport' content='width=device-width, initial-scale=1'>\n",
          "<title>MIA Chat History</title>\n",
          "<style>\n",
          "body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; background-color: #f8f9fa; color: #333; }\n",
          ".chat-container { display: flex; flex-direction: column; gap: 15px; }\n",
          ".message { padding: 15px; border-radius: 12px; max-width: 85%; line-height: 1.5; box-shadow: 0 1px 2px rgba(0,0,0,0.1); }\n",
          ".user { align-self: flex-end; background-color: #007bff; color: white; border-bottom-right-radius: 2px; }\n",
          ".assistant { align-self: flex-start; background-color: #ffffff; border-bottom-left-radius: 2px; border: 1px solid #dee2e6; }\n",
          ".role-label { font-size: 0.8em; margin-bottom: 5px; opacity: 0.8; font-weight: bold; }\n",
          "img { max-width: 100%; border-radius: 8px; margin-top: 10px; border: 1px solid rgba(255,255,255,0.2); }\n",
          "pre { background: rgba(0,0,0,0.05); padding: 10px; border-radius: 5px; overflow-x: auto; white-space: pre-wrap; }\n",
          ".user pre { background: rgba(255,255,255,0.1); }\n",
          "a { color: inherit; text-decoration: underline; }\n",
          "code { background: rgba(0,0,0,0.05); padding: 2px 5px; border-radius: 3px; }\n",
          "</style>\n",
          "</head><body>\n",
          "<div style='text-align: center; margin-bottom: 30px;'>\n",
          "<h1>🤖 MIA Chat History</h1>\n",
          "<p>Exported on ", format(Sys.time(), "%B %d, %Y at %H:%M"), "</p>\n",
          "</div>\n",
          "<div class='chat-container'>\n"
        )
        
        cat("HTML header created\n")
        
        # Process messages
        messages_html <- c()
        for (i in seq_along(messages)) {
          tryCatch({
            cat("Processing message", i, "\n")
            msg <- messages[[i]]
            
            role <- msg$role
            content <- msg$content
            
            cat("Message", i, "role:", role, "\n")
            
            if (is.null(role) || role == "system") {
              cat("Skipping system message\n")
              next
            }
            
            role_cls <- if (role == "user") "user" else "assistant"
            role_name <- if (role == "user") "You" else "MIA"
            
            cat("Content length:", nchar(content), "\n")
            
            content_html <- ""
            
            # Content is always character from our manual tracking
            if (is.character(content) && length(content) > 0 && nzchar(trimws(content))) {
              cat("Processing character content\n")
              # Use markdown::mark for modern markdown rendering
              content_html <- tryCatch({
                result <- as.character(markdown::mark(text = content))
                cat("Markdown result length:", nchar(result), "\n")
                result
              }, error = function(e) {
                cat("Markdown error:", e$message, "\n")
                # Fallback to plain text with HTML escaping
                paste0("<p>", gsub("<", "&lt;", gsub(">", "&gt;", content)), "</p>")
              })
            }
            
            # Only add message if there's content
            if (nzchar(content_html)) {
              msg <- paste0(
                "<div class='message ", role_cls, "'>\n",
                "<div class='role-label'>", role_name, "</div>\n",
                content_html, "\n",
                "</div>\n"
              )
              messages_html <- c(messages_html, msg)
              cat("Added message", i, "to output\n")
            } else {
              cat("Skipping turn", i, "- no content\n")
            }
          }, error = function(e) {
            # Log error but continue processing other messages
            cat("Error processing turn", i, "in download:", e$message, "\n")
            print(e)
          })
        }
        
        cat("Processed", length(messages_html), "messages\n")
        
        # HTML footer
        html_footer <- "</div>\n</body></html>"
        
        # Combine all parts
        complete_html <- paste0(html_header, paste(messages_html, collapse = ""), html_footer)
        
        cat("Writing to file...\n")
        # Write to file with UTF-8 encoding
        writeLines(complete_html, file, useBytes = FALSE)
        cat("Download complete!\n")
        
      }, error = function(e) {
        cat("Critical error in download handler:", e$message, "\n")
        print(e)
        traceback()
        # Write a simple error page
        error_msg <- gsub("<", "&lt;", gsub(">", "&gt;", e$message))
        writeLines(paste0(
          "<!DOCTYPE html><html><head><meta charset='utf-8'><title>Error</title></head><body>",
          "<h1>Error generating chat history</h1>",
          "<p>", error_msg, "</p>",
          "<pre>", paste(capture.output(print(e)), collapse="\n"), "</pre>",
          "</body></html>"
        ), file)
      })
    }
  )
}