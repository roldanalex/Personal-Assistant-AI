page_sidebar(
  title = "Personal AI Chatbot (Powered by OpenAI GTP models)",
  subtitle = "Created by Alexis Roldan",
  theme = my_theme,
  sidebar = sidebar(
    open = "open",
    radioButtons(
      "current_theme", "App Theme:",
      c("Light" = "cerulean", "Dark" = "darkly"),
      selected = "darkly",
      inline = TRUE
    ),
    selectInput(
      "model", "Select your GTP model",
      choices = c("gpt-3.5-turbo", "gpt-4"),
      selected = "gpt-3.5-turbo"),
    selectInput(
      "task", "Select your prompt type",
      choices = list(
        "General" = "general",
        "R Code" = "r_code",
        "Python Code" = "python_code"),
      selected = "general"),
  ),
  textAreaInput(
    "user_prompt", NULL,
    width = "600px",
    height = "300px"),
  actionBttn(
    "send_prompt",
    label = NULL,
    color = "danger",
    size = "md",
    style = "jelly",
    icon = icon("paper-plane"),
    width = "80px",
    block = FALSE),
  # actionButton(
  #   "chat", NULL, 
  #   icon = icon("paper-plane"),
  #   width = "80px",
  #   class = "m-2 btn-success"
  # ),
  uiOutput("chat_history")
)