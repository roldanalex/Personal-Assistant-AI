library(shiny)
library(bslib)
library(httr2)
library(purrr)
library(glue)

source("utils/functions.R")

# Setup the bslib theme object
my_theme <- bs_theme(
  bootswatch = "darkly",
  base_font = font_google("Righteous"))

ui <- page_sidebar(
  title = "Personal AI Chatbot (Powered by OpenAI GTP models)",
  theme = my_theme,
  sidebar = sidebar(
    open = "open",
    selectInput("model", "Model",
                choices = c("gpt-3.5-turbo", "gpt-4")),
    selectInput("task", "Task",
                choices = c("general", "code")),
    radioButtons(
      "current_theme", "App Theme:",
      c("Light" = "cerulean", "Dark" = "darkly"),
      inline = TRUE
    )
  ),
  textAreaInput("prompt", NULL, width = "400px"),
  actionButton(
    "chat", NULL,
    icon = icon("paper-plane"),
    width = "75px",
    class = "m-2 btn-secondary"
    ),
  uiOutput("chat_history")
)

server <- function(input, output, session) {

  react_val <- reactiveValues()
  react_val$chat_history <- NULL

  observe({
    # Make sure theme is kept current with desired
    session$setCurrentTheme(
      bs_theme_update(my_theme, bootswatch = input$current_theme)
    )
  })

  observe({

    req(input$prompt != "")
    response <- chat_response(
      input$prompt,
      history = react_val$chat_history,
      system_prompt = input$task)

    react_val$chat_history <- update_history(
      react_val$chat_history, input$prompt, response)

    output$chat_history <- renderUI(
      map(
        react_val$chat_history, \(x) markdown(glue("{x$role}: {x$content}"))
      )
    )

  }) |> bindEvent(input$chat)

}

shinyApp(ui, server)
