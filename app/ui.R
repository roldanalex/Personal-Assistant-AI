page_sidebar(
  title = tags$span(style = "font-size: 1.5rem; font-weight: bold;", " 'Lucy' - Personal AI Chatbot (Powered by OpenAI)"),
  fillable = TRUE,
  theme = my_theme,
  useShinyjs(),
  
  # Link to external CSS file and favicon
  tags$head(
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
  
  uiOutput("current_user"),

  # ---- Login/Signup Modal Overlay ----
  tags$div(
    id = "auth-panel",
    tags$div(
      id = "welcome-panel",
      tags$div(style = "font-size: 64px; margin-bottom: 10px;", "🤖"),
      tags$h2("Welcome to Lucy"),
      tags$p("Personal AI Chatbot (Powered by OpenAI)"),
      tags$div(id = "auth-forms")
    )
  ),

  # ---- Sidebar (always present but hidden initially) ----
  sidebar = sidebar(
    id = "main-sidebar",
    open = "open",
    class = "sidebar-hidden",  # Use CSS class instead of inline style
    radioButtons(
      "current_theme", "App Theme:",
      c("Light" = "zephyr", "Dark" = "darkly"),
      selected = "darkly",
      inline = TRUE
    ),
    selectInput(
      "model",
      "Intelligence Level:",
      choices = list(
        "Best Quality (GPT-4)" = "gpt-4.1",
        "Fast Speed (GPT-3.5)" = "gpt-3.5-turbo"
      ),
      selected = "gpt-4.1"
    ),
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

  # ---- Main Content (always present but hidden initially) ----
  card(
    id = "main-content-panel",
    class = "content-hidden border-0 bg-transparent",
    # Help buttons in top-right corner
    tags$div(
      class = "help-buttons-container",
      style = "position: fixed; top: 20px; right: 20px; z-index: 1100; display: flex; gap: 8px;",
      actionButton(
        "btn_user_guide",
        label = NULL,
        icon = icon("book"),
        class = "btn-danger btn-sm",
        title = "User Guide",
        style = "border-radius: 50%; width: 40px; height: 40px; padding: 0; display: flex; align-items: center; justify-content: center;",
        `data-bs-toggle` = "modal", `data-bs-target` = "#userGuideModal",
        `data-toggle` = "modal", `data-target` = "#userGuideModal"
      ),
      actionButton(
        "btn_release_notes",
        label = NULL,
        icon = icon("clipboard-list"),
        class = "btn-danger btn-sm",
        title = "Release Notes",
        style = "border-radius: 50%; width: 40px; height: 40px; padding: 0; display: flex; align-items: center; justify-content: center;",
        `data-bs-toggle` = "modal", `data-bs-target` = "#releaseNotesModal",
        `data-toggle` = "modal", `data-target` = "#releaseNotesModal"
      )
    ),
    card_body(chat_ui("chat")),
    tags$div(
      id = "chat-status-container",
      style = "min-height: 24px; margin-top: 5px; margin-left: 10px; font-style: italic; color: #6c757d; font-size: 0.9em;",
      uiOutput("chat_status")
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
        column(4, "© Alexis Roldan - 2023"),
        column(4, "Personal Chatbot v1.3.1"),
        column(
          4,
          tags$a(
            href = "mailto:alexis.m.roldan.ds@gmail.com",
            tags$b("Email me"),
            class = "externallink footer-link"
          )
        )
      ),
      class = "app-footer"
    ),
    tags$div(
      class = "floating-action-container",
      actionButton(
        inputId = "new_chat",
        label = NULL,
        icon = icon("comments"),
        class = "btn-danger btn-lg new-chat-button"
      ),
      tags$div(
        "New chat",
        class = "new-chat-label"
      )
    )
  ),
  
  # ---- User Guide Modal ----
  tags$div(
    class = "modal fade", id = "userGuideModal", tabindex = "-1", role = "dialog",
    tags$div(
      class = "modal-dialog modal-lg", role = "document",
      tags$div(
        class = "modal-content",
        tags$div(
          class = "modal-header",
          tags$h5(class = "modal-title", "User Guide"),
          tags$button(type = "button", class = "close", `data-bs-dismiss`="modal", `data-dismiss`="modal", aria_label = "Close", tags$span(aria_hidden = "true", "×"))
        ),
        tags$div(
          class = "modal-body",
          includeMarkdown("markdown/user_guide.md")
        ),
        tags$div(
          class = "modal-footer",
          tags$button(type = "button", class = "btn btn-danger", `data-bs-dismiss`="modal", `data-dismiss`="modal", "Close")
        )
      )
    )
  ),
  
  # ---- Release Notes Modal ----
  tags$div(
    class = "modal fade", id = "releaseNotesModal", tabindex = "-1", role = "dialog",
    tags$div(
      class = "modal-dialog modal-lg", role = "document",
      tags$div(
        class = "modal-content",
        tags$div(
          class = "modal-header",
          tags$h5(class = "modal-title", "🎉 Release Notes"),
          tags$button(type = "button", class = "close", `data-bs-dismiss`="modal", `data-dismiss`="modal", aria_label = "Close", tags$span(aria_hidden = "true", "×"))
        ),
        tags$div(
          class = "modal-body",
          includeMarkdown("markdown/release_notes.md")
        ),
        tags$div(
          class = "modal-footer",
          tags$button(type = "button", class = "btn btn-danger", `data-bs-dismiss`="modal", `data-dismiss`="modal", "Close")
        )
      )
    )
  ),
    # JS to clear fileInput UI when needed
    tags$script("
      Shiny.addCustomMessageHandler('resetFileInput', function(id) {
        setTimeout(function() {
          var $el = $('#' + id);
          if ($el.length) {
            // Clear the file input value
            $el.val('');
            
            // Reset the form containing the file input
            var form = $el.closest('form')[0];
            if (form) {
              form.reset();
            } else {
              // If no form, create temporary form for reset
              $el.wrap('<form>').closest('form').get(0).reset();
              $el.unwrap();
            }
            
            // Trigger change event to update Shiny
            $el.trigger('change');
            
            // Clear any file preview elements (progress bars, etc.)
            $el.siblings('.progress').remove();
            $el.siblings('.file-input-name').remove();
            
            // Clear Bootstrap file input styling and text
            var $parent = $el.closest('.form-group');
            $parent.find('.custom-file-label').text('Choose file');
            $parent.find('.form-control-file').val('');
            
            // Clear any Shiny file input status messages
            $parent.find('.shiny-input-container .help-block').remove();
            $parent.find('.progress').remove();
            
            // Force re-render of file input widget
            $el.closest('.shiny-input-container').find('.progress').hide();
            
            // Additional cleanup for Shiny's file input
            var $container = $el.closest('.shiny-input-container');
            $container.find('.progress-bar').remove();
            $container.find('.alert').remove();
            
            // Reset the file input completely
            $el.replaceWith($el.val('').clone(true));
          }
        }, 100); // Small delay to ensure DOM is ready
      });
      
      // New handler specifically for clearing UI status only (not reactive values)
      Shiny.addCustomMessageHandler('clearFileInputStatus', function(id) {
        setTimeout(function() {
          var $el = $('#' + id);
          if ($el.length) {
            var $container = $el.closest('.shiny-input-container');
            
            // Remove all status indicators
            $container.find('.progress').remove();
            $container.find('.progress-bar').remove();
            $container.find('.alert').remove();
            $container.find('.help-block').remove();
            
            // Hide any upload status text
            $container.find('.shiny-file-input-progress').hide();
            $container.find('.shiny-file-input-active').removeClass('shiny-file-input-active');
            
            // Reset visual state without clearing the actual file input
            var $parent = $el.closest('.form-group');
            $parent.find('.custom-file-label').text('Choose file');
          }
        }, 50);
      });
    "),
    # Insert dynamic forms for login/signup/reset via JS
    tags$script(HTML("
      function showAuthForm(which) {
        let forms = {
          login: `
            <form id='login-form'>
              <div class='form-group'>
                <input class='form-control' id='login_user' placeholder='Username' autofocus>
              </div>
              <div class='form-group'>
                <input class='form-control' id='login_password' placeholder='Password' type='password'>
              </div>
              <button type='submit' class='btn btn-danger btn-block'>Log in</button>
              <div style='margin-top:18px;font-size:0.92em;text-align:center;'>
                <span id='show_signup' style='color:#888;cursor:not-allowed;'>Sign up (Disabled)</span>
                &nbsp;|&nbsp;
                <a href='#' id='show_reset'>Reset password</a>
              </div>
            </form>
          `,
          signup: `
            <form id='signup-form'>
              <div class='form-group'>
                <input class='form-control' id='signup_user' placeholder='Choose username' autofocus>
              </div>
              <div class='form-group'>
                <input class='form-control' id='signup_password' placeholder='Choose password' type='password'>
              </div>
              <button type='submit' class='btn btn-danger btn-block'>Sign Up</button>
              <div style='margin-top:14px;'><a href='#' id='back_login1'>Back to login</a></div>
            </form>
          `,
          reset: `
            <form id='reset-form'>
              <div class='form-group'>
                <input class='form-control' id='reset_user' placeholder='Your username' autofocus>
              </div>
              <div class='form-group'>
                <input class='form-control' id='reset_password' placeholder='New password' type='password'>
              </div>
              <button type='submit' class='btn btn-danger btn-block'>Reset Password</button>
              <div style='margin-top:14px;'><a href='#' id='back_login2'>Back to login</a></div>
            </form>
          `
        };
        $('#auth-forms').html(forms[which]);
      }
      // Show login form on first load
      document.addEventListener('DOMContentLoaded', function() {
        showAuthForm('login');
      });

      // Listen for dynamic events after form change
      $(document).on('click', '#show_signup', function(e){
        e.preventDefault(); 
        // Sign up is currently disabled
        alert('Sign up is currently unavailable. Please contact the administrator for access.');
        return false;
      });
      $(document).on('click', '#show_reset', function(e){
        e.preventDefault(); showAuthForm('reset');
      });
      $(document).on('click', '#back_login1', function(e){
        e.preventDefault(); showAuthForm('login');
      });
      $(document).on('click', '#back_login2', function(e){
        e.preventDefault(); showAuthForm('login');
      });

      // Forward form submits to Shiny
      $(document).on('submit', '#login-form', function(e){
        e.preventDefault();
        Shiny.setInputValue('auth__login', {
          user: $('#login_user').val(),
          password: $('#login_password').val(),
          nonce: Math.random()
        });
      });
      $(document).on('submit', '#signup-form', function(e){
        e.preventDefault();
        Shiny.setInputValue('auth__signup', {
          user: $('#signup_user').val(),
          password: $('#signup_password').val(),
          nonce: Math.random()
        });
      });
      $(document).on('submit', '#reset-form', function(e){
        e.preventDefault();
        Shiny.setInputValue('auth__reset', {
          user: $('#reset_user').val(),
          password: $('#reset_password').val(),
          nonce: Math.random()
        });
      });

      // Handler for server-initiated auth form switch
      Shiny.addCustomMessageHandler('resetAuthForm', function(data) {
        if(data.form === 'login') showAuthForm('login');
        else if(data.form === 'signup') showAuthForm('signup');
        else if(data.form === 'reset') showAuthForm('reset');
      });
    ")),
    # ---- Speech-to-Text & Camera Integration ----
    tags$script(HTML("
      $(document).ready(function() {
        // Speech Recognition Setup
        var SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
        if (SpeechRecognition) {
          var recognition = new SpeechRecognition();
          recognition.continuous = true;  // Keep listening until silence timeout
          recognition.interimResults = false;
          var silenceTimer;

          $('#btn_speech').on('click', function() {
            // Adjust language based on selected task
            var task = $('#task').val();
            recognition.lang = (task === 'agente_primaria') ? 'es-ES' : 'en-US';
            
            var $btn = $(this);
            var $icon = $btn.find('i');
            var originalIconClass = $icon.attr('class');
            
            $icon.removeClass().addClass('fa fa-spinner fa-spin');
            $btn.addClass('listening-pulse');
            
            try {
              recognition.start();
            } catch(e) {
              console.log('Recognition already started or error:', e);
            }
            
            // Reset silence timer on start
            clearTimeout(silenceTimer);

            recognition.onend = function() {
              $icon.attr('class', originalIconClass);
              $btn.removeClass('listening-pulse');
              clearTimeout(silenceTimer);
            };
          });

          recognition.onresult = function(event) {
            // Reset silence timer: Stop after 3 seconds of no speech
            clearTimeout(silenceTimer);
            silenceTimer = setTimeout(function() { recognition.stop(); }, 3000);
            
            // Get the latest result (last in the array)
            var lastIdx = event.results.length - 1;
            var transcript = event.results[lastIdx][0].transcript;
            
            // Target the chat textarea
            var $input = $('#main-content-panel textarea').first();
            if ($input.length) {
              var currentVal = $input.val();
              var newVal = currentVal ? currentVal + ' ' + transcript : transcript;
              $input.val(newVal);
              $input.trigger('input'); // Notify Shiny
              $input.trigger('change');
            }
          };
        } else {
          $('#btn_speech').hide();
        }

        // Camera/Upload Button
        $('#btn_camera').on('click', function() {
          $('#uploaded_image').click();
        });
      });
    "))
)