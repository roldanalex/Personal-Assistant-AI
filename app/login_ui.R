login_ui_view <- function() {
  tagList(
    tags$div(
      id = "auth-panel",
      tags$div(
        id = "welcome-panel",
        tags$div(class = "mia-login-wordmark", "MIA"),
        tags$p(class = "mia-login-tagline", "Tu asistente educativo inteligente"),
        tags$div(id = "auth-forms")
      )
    ),

    tags$script(HTML("
      function showAuthForm(which) {
        let forms = {
          login: `
            <form id='login-form'>
              <div class='form-group'>
                <label for='login_user' class='form-label'>Usuario</label>
                <input class='form-control' id='login_user' placeholder='Tu nombre de usuario' autofocus>
              </div>
              <div class='form-group'>
                <label for='login_password' class='form-label'>Contrase\\u00f1a</label>
                <input class='form-control' id='login_password' placeholder='Tu contrase\\u00f1a' type='password'>
              </div>
              <button type='submit' class='btn btn-primary btn-block'>Ingresar</button>
              <div class='auth-links'>
                <a href='#' id='show_signup'>Crear cuenta</a>
                &nbsp;|&nbsp;
                <a href='#' id='show_reset'>Recuperar contrase\\u00f1a</a>
              </div>
              <div class='privacy-link'>
                Al ingresar, aceptas nuestros t\\u00e9rminos de uso y pol\\u00edtica de privacidad.
              </div>
            </form>
          `,
          signup: `
            <form id='signup-form'>
              <div class='form-group'>
                <label for='signup_user' class='form-label'>Elige un usuario</label>
                <input class='form-control' id='signup_user' placeholder='Nombre de usuario' autofocus>
              </div>
              <div class='form-group'>
                <label for='signup_password' class='form-label'>Elige una contrase\\u00f1a</label>
                <input class='form-control' id='signup_password' placeholder='Contrase\\u00f1a' type='password'>
              </div>
              <button type='submit' class='btn btn-primary btn-block'>Crear cuenta</button>
              <div class='auth-links'>
                <a href='#' id='back_login1'>Volver al inicio</a>
              </div>
            </form>
          `,
          reset: `
            <form id='reset-form'>
              <div class='form-group'>
                <label for='reset_user' class='form-label'>Tu usuario</label>
                <input class='form-control' id='reset_user' placeholder='Nombre de usuario' autofocus>
              </div>
              <div class='form-group'>
                <label for='reset_password' class='form-label'>Nueva contrase\\u00f1a</label>
                <input class='form-control' id='reset_password' placeholder='Nueva contrase\\u00f1a' type='password'>
              </div>
              <button type='submit' class='btn btn-primary btn-block'>Cambiar contrase\\u00f1a</button>
              <div class='auth-links'>
                <a href='#' id='back_login2'>Volver al inicio</a>
              </div>
            </form>
          `
        };
        $('#auth-forms').html(forms[which]);
      }

      $(document).ready(function() {
        showAuthForm('login');
        $('#auth-panel').addClass('visible');
      });

      $(document).on('click', '#show_signup', function(e){ e.preventDefault(); showAuthForm('signup'); });
      $(document).on('click', '#show_reset', function(e){ e.preventDefault(); showAuthForm('reset'); });
      $(document).on('click', '#back_login1', function(e){ e.preventDefault(); showAuthForm('login'); });
      $(document).on('click', '#back_login2', function(e){ e.preventDefault(); showAuthForm('login'); });

      $(document).on('submit', '#login-form', function(e){
        e.preventDefault();
        Shiny.setInputValue('auth__login', { user: $('#login_user').val(), password: $('#login_password').val(), nonce: Math.random() });
      });
      $(document).on('submit', '#signup-form', function(e){
        e.preventDefault();
        Shiny.setInputValue('auth__signup', { user: $('#signup_user').val(), password: $('#signup_password').val(), nonce: Math.random() });
      });
      $(document).on('submit', '#reset-form', function(e){
        e.preventDefault();
        Shiny.setInputValue('auth__reset', { user: $('#reset_user').val(), password: $('#reset_password').val(), nonce: Math.random() });
      });

      Shiny.addCustomMessageHandler('resetAuthForm', function(data) {
        if(data.form === 'login') showAuthForm('login');
        else if(data.form === 'signup') showAuthForm('signup');
        else if(data.form === 'reset') showAuthForm('reset');
      });
    "))
  )
}
