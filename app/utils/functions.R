my_theme <- bs_theme(
  bootswatch = "darkly",
  heading_font = font_google("Lobster"),
  base_font = font_collection(
    font_google("Roboto Slab"), font_google("Merriweather")
  ),
  code_font = font_google("Inconsolata")
)

get_system_prompt <- function(system = c("general", "r_code", "python_code", "sql_code")) {
  rlang::arg_match(system)
  switch(
    system,
    "general" = "You are a useful and resourceful assistant.",
    "r_code" = "You are a resourceful and efficient chat bot that answers questions for an R programmer.",
    "python_code" = "You are an efficient and resourceful chat bot that answers questions for a Python programmer.",
    "sql_code" = "You are an efficient and resourceful chat bot that answers questions for a SQL developer"
  )
}
