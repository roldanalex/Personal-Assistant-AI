page_sidebar(
  title = " 'Lucy' - Personal AI Chatbot (Powered by OpenAI)",
  theme = my_theme,
  useShinyjs(),
  
  # Link to external CSS file
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
  ),
  
  uiOutput("current_user"),

  # ---- Login/Signup Modal Overlay ----
  tags$div(
    id = "auth-panel",
    tags$div(
      id = "welcome-panel",
      tags$img(src = "https://em-content.zobj.net/source/telegram/386/robot_1f916.png",
               height = 64, class = "welcome-logo"),
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
        "SQL Code" = "sql_code",
        "Agente Primaria (Español)" = "agente_primaria"
      ),
      selected = "general"
    ),
    fileInput(
      "uploaded_image",
      "Attach image(s) to send:",
      multiple = TRUE,
      accept = c("image/png", "image/jpeg", "image/jpg")
    ),
    uiOutput("show_uploaded_images")
  ),

  # ---- Main Content (always present but hidden initially) ----
  tags$div(
    id = "main-content-panel",
    class = "content-hidden",  # Use CSS class from external stylesheet
    chat_ui("chat"),
    div(class = "bottom-spacer"),
    tags$footer(
      fluidRow(
        column(4, "© Alexis Roldan - 2023"),
        column(4, "Personal Chatbot v1.2.2"),
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
        class = "btn-primary btn-lg new-chat-button"
      ),
      tags$div(
        "New chat",
        class = "new-chat-label"
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
              <button type='submit' class='btn btn-primary btn-block'>Log in</button>
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
              <button type='submit' class='btn btn-success btn-block'>Sign Up</button>
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
              <button type='submit' class='btn btn-warning btn-block'>Reset Password</button>
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
    "))
)