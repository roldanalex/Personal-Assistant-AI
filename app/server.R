function(input, output, session) {

  react_val <- reactiveValues()
  react_val$chat_history <- NULL
  
  observeEvent(input$current_theme, {
    # Make sure theme is kept current with desired
    session$setCurrentTheme(
      bs_theme_update(
        my_theme, bootswatch = input$current_theme)
    )
  })
  
  observeEvent(input$send_prompt, {
    
    req(input$user_prompt != "")
    response <- chat_response(
      input$user_prompt,
      history = react_val$chat_history,
      system_prompt = input$task,
      model = input$model)
    
    react_val$chat_history <- update_history(
      react_val$chat_history, input$user_prompt, response)
    
    output$chat_history <- renderUI(
      map(
        react_val$chat_history, \(x) markdown(glue("{x$role}: {x$content}"))
      )
    )
    
    updateTextInput(session, "user_prompt", value = "")
    
  })

}