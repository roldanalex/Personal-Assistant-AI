ui <- function(request) {
  tagList(
  useShinyjs(),

  tags$head(
    tags$link(rel = "stylesheet", href = "https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;600;700&family=Source+Sans+3:wght@400;600&family=JetBrains+Mono:wght@400;500&display=swap"),
    # MIA "M" lettermark favicon
    tags$link(rel = "icon", href = "data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><rect width=%22100%22 height=%22100%22 rx=%2220%22 fill=%22%231565C0%22/><text x=%2250%22 y=%2272%22 font-size=%2260%22 font-weight=%22bold%22 font-family=%22system-ui%22 fill=%22white%22 text-anchor=%22middle%22>M</text></svg>"),
    tags$link(rel = "stylesheet", type = "text/css", href = "style.css"),
    tags$style(HTML("
      @keyframes pulse-blue {
        0% { box-shadow: 0 0 0 0 rgba(21, 101, 192, 0.7); }
        70% { box-shadow: 0 0 0 10px rgba(21, 101, 192, 0); }
        100% { box-shadow: 0 0 0 0 rgba(21, 101, 192, 0); }
      }
      .listening-pulse {
        animation: pulse-blue 1.5s infinite;
      }
    "))
  ),

  uiOutput("main_view"),

  # Global JavaScript for button handlers and speech recognition
  tags$script(HTML("
    // File upload trigger
    $(document).on('click', '#btn_camera', function() {
      $('#uploaded_image').click();
    });

    // Track current persona for speech language detection
    var currentPersona = 'general';
    var spanishPersonas = ['agente_primaria', 'pre_universitario', 'asistente_mype', 'tramites_peru'];

    Shiny.addCustomMessageHandler('setCurrentPersona', function(persona) {
      currentPersona = persona;
    });

    // Speech recognition
    $(document).ready(function() {
      var SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
      if (!SpeechRecognition) return;

      var recognition = new SpeechRecognition();
      recognition.continuous = true;
      recognition.interimResults = false;
      var silenceTimer;
      var isListening = false;

      $(document).on('click', '#btn_speech', function() {
        if (isListening) {
          recognition.stop();
          return;
        }

        recognition.lang = spanishPersonas.includes(currentPersona) ? 'es-PE' : 'en-US';

        var $btn = $(this);
        var $icon = $btn.find('i');
        var originalIconClass = $icon.attr('class');

        $icon.removeClass().addClass('fa fa-spinner fa-spin');
        $btn.addClass('listening-pulse');

        try {
          recognition.start();
          isListening = true;
        } catch(e) {
          $icon.attr('class', originalIconClass);
          $btn.removeClass('listening-pulse');
          isListening = false;
        }

        recognition.onend = function() {
          $icon.attr('class', originalIconClass);
          $btn.removeClass('listening-pulse');
          clearTimeout(silenceTimer);
          isListening = false;
        };

        recognition.onerror = function(event) {
          $icon.attr('class', originalIconClass);
          $btn.removeClass('listening-pulse');
          isListening = false;
        };
      });

      recognition.onresult = function(event) {
        clearTimeout(silenceTimer);
        silenceTimer = setTimeout(function() {
          recognition.stop();
        }, 3000);

        var lastIdx = event.results.length - 1;
        var transcript = event.results[lastIdx][0].transcript;

        var $input = $('#main-content-panel textarea').first();
        if ($input.length) {
          var currentVal = $input.val();
          var newVal = currentVal ? currentVal + ' ' + transcript : transcript;
          $input.val(newVal);
          $input[0].dispatchEvent(new Event('input', { bubbles: true }));
        }
      };
    });
  "))
  )
}
