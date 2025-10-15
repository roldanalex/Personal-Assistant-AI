page_sidebar(
  title = " 'Lucy' - Personal AI Chatbot (Powered by OpenAI)",
  theme = my_theme,
  sidebar = sidebar(
    open = "open",
    radioButtons(
      "current_theme", "App Theme:",
      c("Light" = "zephyr", "Dark" = "darkly"),
      selected = "darkly",
      inline = TRUE
    ),
    selectInput(
      "model",
      "Select your GPT model:",
      choices = list(
        "GTP-4.1" = "gpt-4.1",
        "GTP-3.5 Turbo" = "gpt-3.5-turbo"
      ),
      selected = "gpt-4.1"
    ),
    selectInput(
      "task",
      "Select your prompt type:",
      choices = list(
        "General" = "general",
        "R Code" = "r_code",
        "Python Code" = "python_code",
        "SQL Code" = "sql_code"
      ),
      selected = "general"
    )
  ),
  chat_ui("chat"),             # <<--- shinychat handles all input/display/history!
  div(style = "margin-bottom: 30px;"),
  tags$footer(
    fluidRow(
      column(4, "© Alexis Roldan - 2023"),
      column(4, "Personal Chatbot v1.2.2"),
      column(
        4,
        tags$a(
          href = "mailto:alexis.m.roldan.ds@gmail.com",
          tags$b("Email me"),
          class = "externallink",
          style = "color: white; text-decoration: none"
        )
      ),
      style = "
        position:fixed;
        text-align:center;
        left: 0;
        bottom:0;
        width:100%;
        z-index:1000;  
        height:30px; /* Height of the footer */
        color: white;
        padding: 3px;
        font-weight: bold;
        background-color: #333333"
    )
  ),
  # Floating "New chat" button
  tags$div(
    style = "
      position: fixed;
      bottom: 80px;
      right: 30px;
      z-index: 1100;",
    actionButton(
      inputId = "new_chat",
      label = NULL,
      icon = icon("comments"),
      class = "btn-primary btn-lg",
      style = "
        border-radius: 50%;
        width: 60px; height: 60px;
        box-shadow: 0 4px 8px rgba(0,0,0,0.2);"
    ),
    tags$div(
      "New chat",
      style = "
        text-align: center; 
        color: #333;
        font-size: 14px;
        margin-top: 5px;"
    )
  )
)