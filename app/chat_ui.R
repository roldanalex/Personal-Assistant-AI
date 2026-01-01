chat_ui_view <- function() {
  tagList(
    tags$head(
      tags$link(rel = "stylesheet", href = "https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap")
    ),
    page_sidebar(
      title = tags$span(
        style = "font-family: 'Inter', sans-serif; font-size: 1.6rem; font-weight: 700; letter-spacing: -0.02em;",
        " 'MIA' - Multimodal Intelligent Assistant ",
        tags$span(style = "font-weight: 400; font-size: 0.85em; opacity: 0.8;", "(Powered by OpenAI)")
      ),
      fillable = TRUE,
      theme = my_theme,
      uiOutput("current_user"),

      # ---- Sidebar ----
      sidebar = sidebar(
        id = "main-sidebar",
        open = "closed",
      selectInput(
        "model",
        "Intelligence Level:",
        choices = list(
          "Best Quality (GPT-4)" = "gpt-4.1",
          "Best Reasoning & Coding (GPT-5.1)" = "gpt-5.1"
        ),
        selected = "gpt-4.1"
      ),
      tags$div(
        style = "display: flex; align-items: center; gap: 8px;",
        tags$div(
          style = "flex: 1;",
          selectInput(
            "task",
            "I need help with:",
            choices = list(
              "General" = "general",
              "Mother Assistant (English)" = "mother_assistant",
              "Agente Primaria (Español)" = "agente_primaria",
              "Pre-Universitario (UNI/San Marcos)" = "pre_universitario",
              "Asistente MYPE (Negocios)" = "asistente_mype",
              "Trámites Perú (SUNAT/RENIEC)" = "tramites_peru",
              "Inglés para Titulación" = "ingles_titulacion",
              "R Programmer" = "r_code",
              "Python Programmer" = "python_code",
              "SQL Programmer" = "sql_code"
            ),
            selected = "general"
          )
        ),
        actionButton(
          "btn_persona_help",
          label = NULL,
          icon = icon("question-circle"),
          class = "btn-danger btn-sm",
          title = "Learn about different assistants",
          style = "margin-top: 25px; border-radius: 50%; width: 32px; height: 32px; padding: 0; display: flex; align-items: center; justify-content: center;",
          `data-bs-toggle` = "modal",
          `data-bs-target` = "#personaHelpModal",
          `data-toggle` = "modal",
          `data-target` = "#personaHelpModal"
        )
      ),
      tags$div(
        style = "display: none;",
        fileInput(
          "uploaded_image",
          label = NULL,
          multiple = TRUE,
          accept = c("image/*", ".pdf", ".docx", ".xlsx", ".csv")
        )
      ),
      uiOutput("show_uploaded_images"),
      tags$hr(),
      downloadButton("download_chat", "Download History", class = "btn-danger", style = "width: 100%;")
    ),

    # ---- Main Content ----
    card(
      id = "main-content-panel",
      class = "border-0 bg-transparent",
      # Help buttons in top-right corner
      tags$div(
        class = "help-buttons-container",
        style = "position: fixed; top: 20px; right: 20px; z-index: 1100; display: flex; gap: 8px;",
        actionButton(
          "btn_user_guide", label = NULL, icon = icon("book"), class = "btn-danger btn-sm", title = "User Guide",
          style = "border-radius: 50%; width: 40px; height: 40px; padding: 0; display: flex; align-items: center; justify-content: center;",
          `data-bs-toggle` = "modal", `data-bs-target` = "#userGuideModal", `data-toggle` = "modal", `data-target` = "#userGuideModal"
        ),
        actionButton(
          "btn_release_notes", label = NULL, icon = icon("clipboard-list"), class = "btn-danger btn-sm", title = "Release Notes",
          style = "border-radius: 50%; width: 40px; height: 40px; padding: 0; display: flex; align-items: center; justify-content: center;",
          `data-bs-toggle` = "modal", `data-bs-target` = "#releaseNotesModal", `data-toggle` = "modal", `data-target` = "#releaseNotesModal"
        )
      ),
      card_body(chat_ui("chat")),
      tags$div(
        id = "chat-status-container",
        style = "min-height: 24px; margin-top: 5px; margin-left: 10px; font-style: italic; color: #6c757d; font-size: 0.9em;",
        tags$div(id = "chat_status")
      ),
      tags$div(
        class = "input-controls-container",
        style = "position: fixed; bottom: 40px; left: 50%; transform: translateX(-50%); display: flex; justify-content: center; gap: 10px; z-index: 1050; background-color: transparent;",
        actionButton("btn_speech", "Speak", icon = icon("microphone"), class = "btn-danger btn-sm", title = "Dictate your message"),
        actionButton("btn_camera", "Attach", icon = icon("paperclip"), class = "btn-danger btn-sm", title = "Upload a file or photo")
      ),
      div(class = "bottom-spacer", style = "height: 80px;"),
      tags$footer(
        fluidRow(
          column(4, "© Alexis Roldan - 2024"),
          column(4, "Personal Chatbot v1.3.2"),
          column(4, tags$a(href = "mailto:alexis.m.roldan.ds@gmail.com", tags$b("Email me"), class = "externallink footer-link"))
        ),
        class = "app-footer"
      ),
      tags$div(
        class = "floating-action-container",
        actionButton(inputId = "new_chat", label = NULL, icon = icon("comments"), class = "btn-danger btn-lg new-chat-button"),
        tags$div("New chat", class = "new-chat-label")
      )
    ),
    
    # ---- Modals ----
    tags$div(
      class = "modal fade", id = "userGuideModal", tabindex = "-1", role = "dialog",
      tags$div(class = "modal-dialog modal-lg", role = "document", tags$div(class = "modal-content",
        tags$div(class = "modal-header", tags$h5(class = "modal-title", "User Guide"), tags$button(type = "button", class = "close", `data-bs-dismiss`="modal", `data-dismiss`="modal", aria_label = "Close", tags$span(aria_hidden = "true", "×"))),
        tags$div(class = "modal-body", includeMarkdown("markdown/user_guide.md")),
        tags$div(class = "modal-footer", tags$button(type = "button", class = "btn btn-danger", `data-bs-dismiss`="modal", `data-dismiss`="modal", "Close"))
      ))
    ),
    tags$div(
      class = "modal fade", id = "releaseNotesModal", tabindex = "-1", role = "dialog",
      tags$div(class = "modal-dialog modal-lg", role = "document", tags$div(class = "modal-content",
        tags$div(class = "modal-header", tags$h5(class = "modal-title", "🎉 Release Notes"), tags$button(type = "button", class = "close", `data-bs-dismiss`="modal", `data-dismiss`="modal", aria_label = "Close", tags$span(aria_hidden = "true", "×"))),
        tags$div(class = "modal-body", includeMarkdown("markdown/release_notes.md")),
        tags$div(class = "modal-footer", tags$button(type = "button", class = "btn btn-danger", `data-bs-dismiss`="modal", `data-dismiss`="modal", "Close"))
      ))
    ),
    
    # ---- Persona Help Modal ----
    tags$div(
      class = "modal fade", id = "personaHelpModal", tabindex = "-1", role = "dialog",
      tags$div(class = "modal-dialog modal-xl", role = "document", tags$div(class = "modal-content",
        tags$div(class = "modal-header", 
          tags$h5(class = "modal-title", "🤖 Meet Your AI Assistants"),
          tags$button(type = "button", class = "close", `data-bs-dismiss`="modal", `data-dismiss`="modal", aria_label = "Close", tags$span(aria_hidden = "true", "×"))
        ),
        tags$div(class = "modal-body", style = "max-height: 70vh; overflow-y: auto;",
          tags$p(class = "lead", "MIA offers specialized assistants tailored to different needs. Choose the one that best fits your question!"),
          tags$hr(),
          
          # General Assistant
          tags$div(class = "persona-card", style = "margin-bottom: 20px; padding: 15px; border-left: 4px solid #dc3545; background: #f8f9fa;",
            tags$h5(tags$b("General Assistant"), style = "color: #dc3545;"),
            tags$p("Your all-purpose AI learning companion for any subject or question. Perfect for homework help, concept explanations, research support, and everyday learning across all disciplines. Uses a pedagogy-first approach with clear explanations, step-by-step guidance, and encouragement.")
          ),
          
          # Mother Assistant
          tags$div(class = "persona-card", style = "margin-bottom: 20px; padding: 15px; border-left: 4px solid #e91e63; background: #f8f9fa;",
            tags$h5(tags$b("Mother Assistant"), tags$span(class = "badge badge-info", "English")),
            tags$p("Warm, evidence-based parenting support for mothers and grandmothers raising children ages 0-5. Get practical advice on child development, health, nutrition, sleep, behavior, activities, and daily parenting challenges. Non-judgmental, empowering guidance with current research and pediatric recommendations.")
          ),
          
          # Agente Primaria
          tags$div(class = "persona-card", style = "margin-bottom: 20px; padding: 15px; border-left: 4px solid #ff9800; background: #f8f9fa;",
            tags$h5(tags$b("Agente Primaria"), tags$span(class = "badge badge-warning", "Español")),
            tags$p("Asistente educativo especializado en educación primaria peruana (6-12 años). Alineado con el Currículo Nacional del Perú, brinda apoyo en Comunicación, Matemática, Ciencias, Personal Social, Arte, Educación Física e Inglés. Enfoque por competencias con perspectiva intercultural y evaluación formativa.")
          ),
          
          # Pre-Universitario
          tags$div(class = "persona-card", style = "margin-bottom: 20px; padding: 15px; border-left: 4px solid #9c27b0; background: #f8f9fa;",
            tags$h5(tags$b("Pre-Universitario (UNI/San Marcos)"), tags$span(class = "badge badge-warning", "Español")),
            tags$p("Tutor experto en preparación para exámenes de admisión universitaria en Perú (UNI, San Marcos, PUCP). Desarrolla razonamiento lógico, resolución de problemas paso a paso, y estrategias de examen. Tono exigente y motivador con práctica deliberada en matemáticas, ciencias, y razonamiento verbal.")
          ),
          
          # Asistente MYPE
          tags$div(class = "persona-card", style = "margin-bottom: 20px; padding: 15px; border-left: 4px solid #4caf50; background: #f8f9fa;",
            tags$h5(tags$b("Asistente MYPE (Negocios)"), tags$span(class = "badge badge-warning", "Español")),
            tags$p("Consultor práctico para Micro y Pequeñas Empresas en Perú. Consejos accionables de bajo costo en ventas, marketing, finanzas básicas, atención al cliente, y análisis de datos comerciales. Incluye plantillas de comunicación, estrategias locales, y KPIs simples para MYPEs.")
          ),
          
          # Trámites Perú
          tags$div(class = "persona-card", style = "margin-bottom: 20px; padding: 15px; border-left: 4px solid #2196f3; background: #f8f9fa;",
            tags$h5(tags$b("Trámites Perú (SUNAT/RENIEC)"), tags$span(class = "badge badge-warning", "Español")),
            tags$p("Experto en gestión administrativa y burocracia peruana. Guía paso a paso para trámites con SUNAT, RENIEC, SUNARP, municipalidades y otras entidades públicas. Requisitos, documentos, plazos, costos y enlaces oficiales. Información sobre regímenes tributarios, RUC, DNI, licencias y más.")
          ),
          
          # Inglés para Titulación
          tags$div(class = "persona-card", style = "margin-bottom: 20px; padding: 15px; border-left: 4px solid #00bcd4; background: #f8f9fa;",
            tags$h5(tags$b("Inglés para Titulación"), tags$span(class = "badge badge-warning", "Español"), " ", tags$span(class = "badge badge-info", "English")),
            tags$p("English certification tutor for Peruvian university students preparing for B1/B2 graduation exams. Exam-focused strategies for reading, writing, listening, and speaking. Grammar corrections, vocabulary enhancement, writing assistance, and time management techniques. Professional, encouraging guidance in both English and Spanish.")
          ),
          
          # R Programmer
          tags$div(class = "persona-card", style = "margin-bottom: 20px; padding: 15px; border-left: 4px solid #673ab7; background: #f8f9fa;",
            tags$h5(tags$b("R Programmer"), style = "color: #673ab7;"),
            tags$p("Expert R programming mentor specializing in statistical analysis, data science, and visualization. Comprehensive knowledge of tidyverse, ggplot2, Shiny apps, statistical modeling, and R packages. Best practices for clean code, reproducible research, debugging, and performance optimization.")
          ),
          
          # Python Programmer
          tags$div(class = "persona-card", style = "margin-bottom: 20px; padding: 15px; border-left: 4px solid #ffc107; background: #f8f9fa;",
            tags$h5(tags$b("Python Programmer"), style = "color: #f57c00;"),
            tags$p("Expert Python programming consultant covering data science (NumPy, Pandas, Scikit-learn), web development (Flask, Django, FastAPI), automation, and software engineering. Clean code principles, debugging techniques, testing, async programming, and best practices for production-ready Python applications.")
          ),
          
          # SQL Programmer
          tags$div(class = "persona-card", style = "margin-bottom: 20px; padding: 15px; border-left: 4px solid #607d8b; background: #f8f9fa;",
            tags$h5(tags$b("SQL Programmer"), style = "color: #607d8b;"),
            tags$p("Expert SQL database consultant specializing in query optimization, database design, and data analysis. Coverage of PostgreSQL, MySQL, SQL Server, and SQLite. Advanced techniques including window functions, CTEs, stored procedures, indexing strategies, and performance tuning for complex queries.")
          ),
          
          tags$hr(),
          tags$p(class = "text-muted", style = "font-size: 0.9em;",
            tags$i(class = "fas fa-info-circle"), " ",
            "Tip: You can switch between assistants anytime using the dropdown menu. Each assistant maintains its own specialized knowledge and communication style to best serve your needs."
          )
        ),
        tags$div(class = "modal-footer", 
          tags$button(type = "button", class = "btn btn-danger", `data-bs-dismiss`="modal", `data-dismiss`="modal", "Close")
        )
      ))
    ),

    # ---- Chat JS (Custom Message Handlers) ----
    tags$script("
      Shiny.addCustomMessageHandler('resetFileInput', function(id) {
        setTimeout(function() {
          var $el = $('#' + id);
          if ($el.length) {
            $el.val('');
            var form = $el.closest('form')[0];
            if (form) form.reset(); else { $el.wrap('<form>').closest('form').get(0).reset(); $el.unwrap(); }
            $el.trigger('change');
            $el.siblings('.progress').remove(); $el.siblings('.file-input-name').remove();
            var $parent = $el.closest('.form-group');
            $parent.find('.custom-file-label').text('Choose file');
            $parent.find('.form-control-file').val('');
            $parent.find('.shiny-input-container .help-block').remove();
            $parent.find('.progress').remove();
            var $container = $el.closest('.shiny-input-container');
            $container.find('.progress-bar').remove(); $container.find('.alert').remove();
            $el.replaceWith($el.val('').clone(true));
          }
        }, 100);
      });
      
      Shiny.addCustomMessageHandler('clearFileInputStatus', function(id) {
        setTimeout(function() {
          var $el = $('#' + id);
          if ($el.length) {
            var $container = $el.closest('.shiny-input-container');
            $container.find('.progress').remove(); $container.find('.progress-bar').remove();
            $container.find('.alert').remove(); $container.find('.help-block').remove();
            $container.find('.shiny-file-input-progress').hide();
            $container.find('.shiny-file-input-active').removeClass('shiny-file-input-active');
            var $parent = $el.closest('.form-group');
            $parent.find('.custom-file-label').text('Choose file');
          }
        }, 50);
      });
      
      Shiny.addCustomMessageHandler('clearChatStatus', function(message) {
        $('#chat_status').html('');
      });
      
      Shiny.addCustomMessageHandler('enableDownloadButton', function(message) {
        $('#download_chat').prop('disabled', false).removeClass('disabled');
        console.log('Download button enabled');
      });
    "),
    tags$script(HTML("
      // Force Inter font on title after UI renders
      setTimeout(function() {
        $('header .navbar-brand, .bslib-page-title, [class*=\"title\"]').css({
          'font-family': '\'Inter\', sans-serif',
          'font-weight': '700',
          'letter-spacing': '-0.02em'
        });
      }, 100);
    "))
    )
  )
}