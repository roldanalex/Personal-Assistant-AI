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

  # Toggle UI panels based on login state
  observe({
    cat("Login state changed. Logged in:", user_auth$logged_in, "\n")
    if (user_auth$logged_in) {
      cat("Showing main panels...\n")
      shinyjs::hide("auth-panel")
      shinyjs::removeClass("main-sidebar", "sidebar-hidden")
      shinyjs::removeClass("main-content-panel", "content-hidden")
    } else {
      cat("Hiding main panels...\n")
      shinyjs::show("auth-panel")
      shinyjs::addClass("main-sidebar", "sidebar-hidden")
      shinyjs::addClass("main-content-panel", "content-hidden")
    }
  })

  # LOGOUT
  observeEvent(input$log_out, {
    user_auth$logged_in <- FALSE
    user_auth$user <- NULL
    shinyjs::show("auth-panel")
    shinyjs::hide("main-app-panel")
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

  # ---- CHATBOT FUNCTIONALITY ----

  chat_obj <- reactiveVal()
  current_images <- reactiveVal(NULL)

  # THEME OBSERVE
  observeEvent(input$current_theme, {
    req(user_auth$logged_in)
    session$setCurrentTheme(
      bs_theme_update(my_theme, bootswatch = input$current_theme)
    )
  }, ignoreInit = TRUE)

  observeEvent(input$uploaded_image, {
    req(user_auth$logged_in, input$uploaded_image)
    cat("Image uploaded. Files:", nrow(input$uploaded_image), "\n")
    # Store the full uploaded_image data, not just datapath
    current_images(input$uploaded_image)

    # Clear the upload status UI after a brief delay, but keep the images
    Sys.sleep(0.5)  # Let upload complete message show briefly
    session$sendCustomMessage("clearFileInputStatus", "uploaded_image")
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
      h5("Attached images:"),
      lapply(seq_len(nrow(imgs)), function(i) {
        img_file <- imgs$datapath[i]
        ext <- tools::file_ext(imgs$name[i])
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
        tags$img(
          src = data_uri,
          class = "image-preview-large"
        )
      })
    )
  })

  # MAIN CHAT INIT: On login or model/task change, always safely (re-)init chat and greeting
  observeEvent(user_auth$logged_in, {
    req(user_auth$logged_in)

    # Initialize with default values if inputs not ready
    model_val <- if(!is.null(input$model)) input$model else "gpt-4.1"
    task_val <- if(!is.null(input$task)) input$task else "general"

    chat_obj(
      ellmer::chat_openai(
        model = model_val,
        system_prompt = get_system_prompt(task_val)
      )
    )
    chat_clear("chat")
    chat_append("chat", list(
      list(
        role = " ",
        content = "Hi, I'm Lucy, your personal chatbot. How can I help you today?"
      )
    ))
    current_images(NULL)
    session$sendCustomMessage("resetFileInput", "uploaded_image")
  }, ignoreInit = TRUE)

  # Update chat when model or task changes (after login)
  observeEvent(
    { list(input$model, input$task) },
    {
      req(user_auth$logged_in)
      req(input$model, input$task)

      chat_obj(
        ellmer::chat_openai(
          model = input$model,
          system_prompt = get_system_prompt(input$task)
        )
      )
      chat_clear("chat")
      chat_append("chat", list(
        list(
          role = " ",
          content = "Hi, I'm Lucy, your personal chatbot. How can I help you today?"
        )
      ))
      current_images(NULL)
      session$sendCustomMessage("resetFileInput", "uploaded_image")
    },
    ignoreInit = TRUE
  )

  # CHAT SUBMISSION: Only send when everything is truly ready
  observeEvent(input$chat_user_input, {
    req(user_auth$logged_in)
    req(nzchar(input$chat_user_input))
    req(chat_obj())    # ensure chat is initialized

    # Use current_images as the source of truth
    imgs <- current_images()

    # Only manually append user message if there are images
    # shinychat handles text-only messages automatically
    if (!is.null(imgs) && nrow(imgs) > 0) {
      # Prepare user message content with images and text
      user_content_elements <- list()

      # Add images
      image_blocks <- lapply(seq_len(nrow(imgs)), function(i) {
        img_file <- imgs$datapath[i]
        ext <- tools::file_ext(imgs$name[i])
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
            sprintf("%s (%s KB)%s",
              imgs$name[i],
              kb,
              if (nzchar(info)) paste0(" • ", info) else ""
            )
          )
        )
      })
      user_content_elements <- c(user_content_elements, image_blocks)

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
      # Use the datapath from current_images for ellmer
      img_paths <- imgs$datapath
      cat("Sending", length(img_paths), "images to LLM\n")
      args <- lapply(img_paths, ellmer::content_image_file)
    } else {
      cat("No images to send to LLM\n")
    }
    args <- c(args, input$chat_user_input)

    # Send to AI and get response stream
    stream <- do.call(chat_obj()$stream_async, args)
    chat_append("chat", stream)

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
    chat_obj(
      ellmer::chat_openai(
        model = input$model,
        system_prompt = get_system_prompt(input$task)
      )
    )
    chat_append("chat", list(
      list(
        role = " ",
        content = "Hi, I'm Lucy, your personal chatbot. How can I help you today?"
      )
    ))
    # Reset images when starting new chat - this should fully clear everything
    cat("Clearing images for new chat\n")
    current_images(NULL)
    session$sendCustomMessage("resetFileInput", "uploaded_image")
    # Additional reset to ensure complete cleanup
    Sys.sleep(0.1)
    session$sendCustomMessage("resetFileInput", "uploaded_image")
  })
}