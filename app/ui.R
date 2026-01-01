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
  
  uiOutput("main_view"),
  
  # Global JavaScript for button handlers (works with dynamic UI)
  tags$script(HTML("
    // Use event delegation for dynamically rendered buttons
    $(document).on('click', '#btn_camera', function() {
      console.log('Camera button clicked');
      $('#uploaded_image').click();
    });
    
    // Speech recognition setup
    $(document).ready(function() {
      var SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
      if (!SpeechRecognition) {
        console.log('Speech recognition not supported');
        return;
      }
      
      var recognition = new SpeechRecognition();
      recognition.continuous = true;
      recognition.interimResults = false;
      var silenceTimer;
      var isListening = false;
      
      $(document).on('click', '#btn_speech', function() {
        console.log('Speech button clicked');
        if (isListening) {
          console.log('Already listening, stopping...');
          recognition.stop();
          return;
        }
        
        var task = $('#task').val() || 'general';
        recognition.lang = (task === 'agente_primaria') ? 'es-ES' : 'en-US';
        
        var $btn = $(this);
        var $icon = $btn.find('i');
        var originalIconClass = $icon.attr('class');
        
        $icon.removeClass().addClass('fa fa-spinner fa-spin');
        $btn.addClass('listening-pulse');
        
        try {
          recognition.start();
          isListening = true;
          console.log('Speech recognition started');
        } catch(e) {
          console.log('Recognition error:', e);
          $icon.attr('class', originalIconClass);
          $btn.removeClass('listening-pulse');
          isListening = false;
        }
        
        recognition.onend = function() {
          console.log('Speech recognition ended');
          $icon.attr('class', originalIconClass);
          $btn.removeClass('listening-pulse');
          clearTimeout(silenceTimer);
          isListening = false;
        };
        
        recognition.onerror = function(event) {
          console.log('Speech recognition error:', event.error);
          $icon.attr('class', originalIconClass);
          $btn.removeClass('listening-pulse');
          isListening = false;
        };
      });
      
      if (SpeechRecognition) {
        var recognition = new SpeechRecognition();
        recognition.continuous = true;
        recognition.interimResults = false;
        var silenceTimer;
        
        recognition.onresult = function(event) {
          clearTimeout(silenceTimer);
          silenceTimer = setTimeout(function() {
            recognition.stop();
          }, 3000);
          
          var lastIdx = event.results.length - 1;
          var transcript = event.results[lastIdx][0].transcript;
          console.log('Transcript:', transcript);
          
          var $input = $('#main-content-panel textarea').first();
          if ($input.length) {
            var currentVal = $input.val();
            var newVal = currentVal ? currentVal + ' ' + transcript : transcript;
            $input.val(newVal);
            $input[0].dispatchEvent(new Event('input', { bubbles: true }));
          } else {
            console.log('Textarea not found');
          }
        };
      }
    });
  "))
  )
}