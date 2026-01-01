login_ui_view <- function() {
  tagList(
    # ---- Login/Signup Modal Overlay ----
    tags$div(
      id = "auth-panel",
      tags$div(
        id = "welcome-panel",
        tags$div(style = "font-size: 64px; margin-bottom: 10px;", "🤖"),
        tags$h2("Welcome to MIA", style = "font-size: 2.5rem; font-weight: bold; margin-bottom: 15px;"),
        tags$p("Multimodal Intelligent Assistant", style = "font-size: 1.1rem; margin-bottom: 25px;"),
        tags$div(id = "auth-forms")
      )
    ),
    
    # Insert dynamic forms for login/signup/reset via JS
    tags$script(HTML("
      function showAuthForm(which) {
        let forms = {
          login: `
            <form id='login-form'>
              <div class='form-group' style='margin-bottom: 20px;'>
                <input class='form-control' id='login_user' placeholder='Username' autofocus style='height: 20px; font-size: 1.1rem; padding: 10px 14px; border-radius: 8px;'>
              </div>
              <div class='form-group' style='margin-bottom: 20px;'>
                <input class='form-control' id='login_password' placeholder='Password' type='password' style='height: 20px; font-size: 1.1rem; padding: 10px 14px; border-radius: 8px;'>
              </div>
              <button type='submit' class='btn btn-danger btn-block' style='height: 50px; font-size: 1.15rem; font-weight: 600; border-radius: 8px; margin-top: 10px;'>Log in</button>
              <div style='margin-top:18px;font-size:0.92em;text-align:center;'>
                <span id='show_signup' style='color:#888;cursor:not-allowed;'>Sign up (Disabled)</span>
                &nbsp;|&nbsp;
                <a href='#' id='show_reset'>Reset password</a>
              </div>
            </form>
          `,
          signup: `
            <form id='signup-form'>
              <div class='form-group' style='margin-bottom: 20px;'>
                <input class='form-control' id='signup_user' placeholder='Choose username' autofocus style='height: 50px; font-size: 1.1rem; padding: 12px 16px; border-radius: 8px;'>
              </div>
              <div class='form-group' style='margin-bottom: 20px;'>
                <input class='form-control' id='signup_password' placeholder='Choose password' type='password' style='height: 50px; font-size: 1.1rem; padding: 12px 16px; border-radius: 8px;'>
              </div>
              <button type='submit' class='btn btn-danger btn-block' style='height: 50px; font-size: 1.15rem; font-weight: 600; border-radius: 8px; margin-top: 10px;'>Sign Up</button>
              <div style='margin-top:14px;'><a href='#' id='back_login1'>Back to login</a></div>
            </form>
          `,
          reset: `
            <form id='reset-form'>
              <div class='form-group' style='margin-bottom: 20px;'>
                <input class='form-control' id='reset_user' placeholder='Your username' autofocus style='height: 50px; font-size: 1.1rem; padding: 12px 16px; border-radius: 8px;'>
              </div>
              <div class='form-group' style='margin-bottom: 20px;'>
                <input class='form-control' id='reset_password' placeholder='New password' type='password' style='height: 50px; font-size: 1.1rem; padding: 12px 16px; border-radius: 8px;'>
              </div>
              <button type='submit' class='btn btn-danger btn-block' style='height: 50px; font-size: 1.15rem; font-weight: 600; border-radius: 8px; margin-top: 10px;'>Reset Password</button>
              <div style='margin-top:14px;'><a href='#' id='back_login2'>Back to login</a></div>
            </form>
          `
        };
        $('#auth-forms').html(forms[which]);
      }
      // Show login form on first load
      $(document).ready(function() {
        showAuthForm('login');
      });

      // Listen for dynamic events after form change
      $(document).on('click', '#show_signup', function(e){
        e.preventDefault(); 
        alert('Sign up is currently unavailable. Please contact the administrator for access.');
        return false;
      });
      $(document).on('click', '#show_reset', function(e){ e.preventDefault(); showAuthForm('reset'); });
      $(document).on('click', '#back_login1', function(e){ e.preventDefault(); showAuthForm('login'); });
      $(document).on('click', '#back_login2', function(e){ e.preventDefault(); showAuthForm('login'); });

      // Forward form submits to Shiny
      $(document).on('submit', '#login-form', function(e){ e.preventDefault(); Shiny.setInputValue('auth__login', { user: $('#login_user').val(), password: $('#login_password').val(), nonce: Math.random() }); });
      $(document).on('submit', '#signup-form', function(e){ e.preventDefault(); Shiny.setInputValue('auth__signup', { user: $('#signup_user').val(), password: $('#signup_password').val(), nonce: Math.random() }); });
      $(document).on('submit', '#reset-form', function(e){ e.preventDefault(); Shiny.setInputValue('auth__reset', { user: $('#reset_user').val(), password: $('#reset_password').val(), nonce: Math.random() }); });

      Shiny.addCustomMessageHandler('resetAuthForm', function(data) { if(data.form === 'login') showAuthForm('login'); else if(data.form === 'signup') showAuthForm('signup'); else if(data.form === 'reset') showAuthForm('reset'); });
    "))
  )
}