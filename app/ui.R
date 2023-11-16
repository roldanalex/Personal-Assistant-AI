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
      "Select your GTP model:",
      choices = c("gpt-3.5-turbo"),
      selected = "gpt-3.5-turbo"),
    selectInput(
      "task",
      "Select your prompt type:",
      choices = list(
        "General" = "general",
        "R Code" = "r_code",
        "Python Code" = "python_code",
        "SQL Code" = "sql_code"),
      selected = "general"),
  ),
  textAreaInput(
    "user_prompt",
    NULL,
    width = "800px",
    height = "200px"),
  column(
    1,
    shinyBS::bsTooltip(
      id = "send_prompt", placement = 'top',
      title = "Click here to send prompt to 'Lucy'",
      trigger = "hover"),
    actionBttn(
      "send_prompt",
      label = NULL,
      color = "danger",
      size = "md",
      style = "jelly",
      icon = icon("paper-plane"),
      block = TRUE)
  ),
  uiOutput("chat_history"),
  div(style = "margin-bottom: 30px;"),
  tags$footer(
    fluidRow(
      column(4, "© Alexis Roldan - 2023"),
      column(4, "Personal Chatbot v1.1.2"),
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
  )
)