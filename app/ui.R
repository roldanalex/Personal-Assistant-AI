ui <- function(request) {
  tagList(
  useShinyjs(),
  
  # Link to external CSS file and favicon
  tags$head(
    tags$link(rel = "stylesheet", href = "https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap"),
    tags$link(rel = "icon", href = "data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>🤖</text></svg>"),
    tags$link(rel = "stylesheet", type = "text/css", href = "style.css"),
    tags$style(HTML("
      @keyframes pulse-red {
        0% { box-shadow: 0 0 0 0 rgba(220, 53, 69, 0.7); }
        70% { box-shadow: 0 0 0 10px rgba(220, 53, 69, 0); }
        100% { box-shadow: 0 0 0 0 rgba(220, 53, 69, 0); }
      }
      .listening-pulse {
        animation: pulse-red 1.5s infinite;
      }
      /* Mobile Footer Alignment */
      @media (max-width: 576px) {
        .app-footer .col-sm-4 {
          text-align: center;
          margin-bottom: 10px;
        }
      }
    "))
  ),
  
  uiOutput("main_view")
  )
}