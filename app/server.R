function(input, output, session) {

  # Holds the ellmer chat object for THIS session
  chat_obj <- reactiveVal()

  observeEvent(input$current_theme, {
    session$setCurrentTheme(
      bs_theme_update(my_theme, bootswatch = input$current_theme)
    )
  }, ignoreInit = TRUE)

  # Create or reset the chat_obj when model or task changes, clear chat UI, and append greeting
  observeEvent(
    { list(input$model, input$task) },
    {
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
    },
    ignoreInit = TRUE
  )

  # Initialize chat object on first use, and append greeting (only once per session)
  observe({
    if (is.null(chat_obj())) {
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
    }
  })

  # Listen for user message from the shinychat UI
  observeEvent(input$chat_user_input, {
    req(nzchar(input$chat_user_input))
    # Stream ellmer response asynchronously to the shinychat UI
    stream <- chat_obj()$stream_async(input$chat_user_input)
    chat_append("chat", stream)
  })

  observeEvent(input$new_chat, {
  # Clear chat UI
  chat_clear("chat")
  # Optionally, re-init chat_obj to truly clear server-side state too
  chat_obj(
    ellmer::chat_openai(
      model = input$model,
      system_prompt = get_system_prompt(input$task)
    )
  )
  # Add initial greeting
  chat_append("chat", list(
    list(
      role = " ",
      content = "Hi, I'm Lucy, your personal chatbot. How can I help you today?"
    )
  ))
})

}