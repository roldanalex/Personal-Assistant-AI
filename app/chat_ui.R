# ---- Persona Selection Grid ----
persona_selection_ui <- function() {
  tagList(
    # Load Bootstrap JS so modals work on this page
    bs_theme_dependencies(my_theme),
    tags$div(
      class = "persona-selection-container",
      # Dark mode toggle (top-right corner)
      tags$div(
        class = "persona-dark-toggle",
        input_dark_mode(id = "dark_mode_grid", mode = "light")
      ),
      # Header
      tags$div(
        class = "persona-header",
        tags$img(
          src = "mia-logo.svg",
          alt = "MIA",
          width = "64",
          height = "64",
          class = "mia-grid-logo"
        ),
        tags$div(class = "mia-wordmark", "MIA"),
        tags$p(class = "mia-tagline", "Tu asistente educativo inteligente"),
        tags$h2(class = "persona-title",
                "\u00bfEn qu\u00e9 te puedo ayudar hoy?"),
        tags$div(
          class = "persona-user-bar",
          uiOutput("persona_user_display")
        )
      ),

      # Category sections
      tags$div(
        class = "persona-categories",
        lapply(names(persona_categories), function(cat_id) {
          cat_info <- persona_categories[[cat_id]]
          personas_in_cat <- Filter(function(p) p$category == cat_id, persona_metadata)

          if (length(personas_in_cat) == 0) return(NULL)

          tags$div(
            class = "persona-category-section",
            tags$h3(
              class = "category-label",
              icon(cat_info$icon), " ", cat_info$label
            ),
            tags$div(
              class = "persona-cards-grid",
              lapply(personas_in_cat, function(p) {
                tags$div(
                  class = "persona-card-item",
                  `data-persona` = p$id,
                  tabindex = "0",
                  role = "button",
                  `aria-label` = paste("Seleccionar", p$name),
                  tags$div(
                    class = "persona-card-icon",
                    style = paste0("background-color: ", p$color, ";"),
                    icon(p$icon)
                  ),
                  tags$h4(class = "persona-card-name", p$name),
                  tags$p(class = "persona-card-desc", p$desc),
                  tags$div(
                    class = "persona-examples-container",
                    lapply(p$examples, function(ex) {
                      tags$span(
                        class = "example-chip",
                        `data-prompt` = ex,
                        title = ex,
                        ex
                      )
                    })
                  )
                )
              })
            )
          )
        }),

        # Model selector + help links at bottom
        tags$div(
          class = "persona-footer",
          tags$div(
            class = "persona-model-selector",
            tags$label(`for` = "model", "Modelo:"),
            selectInput(
              "model",
              label = NULL,
              choices = list(
                "GPT-4 (Mejor calidad)" = "gpt-4.1",
                "GPT-5.1 (Mejor razonamiento)" = "gpt-5.1"
              ),
              selected = "gpt-4.1",
              width = "220px"
            )
          ),
          tags$div(
            class = "persona-help-links",
            tags$a(
              href = "#", class = "persona-help-link",
              `data-bs-toggle` = "modal", `data-bs-target` = "#personaGuideModal",
              icon("book"), " Gu\u00eda de uso"
            ),
            tags$span(class = "persona-help-separator", "|"),
            tags$a(
              href = "#", class = "persona-help-link",
              `data-bs-toggle` = "modal", `data-bs-target` = "#personaNotesModal",
              icon("clipboard-list"), " Novedades v2.0"
            )
          ),
          tags$div(
            class = "persona-footer-credit",
            "MIA v2.0 | Created by Alexis Roldan - 2025"
          )
        )
      )
    ),

    # Modals for persona grid (User Guide + Release Notes)
    tags$div(
      class = "modal fade", id = "personaGuideModal", tabindex = "-1",
      `aria-labelledby` = "personaGuideLabel", `aria-hidden` = "true",
      tags$div(class = "modal-dialog modal-lg modal-dialog-scrollable",
        tags$div(class = "modal-content",
          tags$div(class = "modal-header",
            tags$h5(class = "modal-title", id = "personaGuideLabel",
                    "Gu\u00eda de Usuario"),
            tags$button(type = "button", class = "btn-close",
              `data-bs-dismiss` = "modal", `aria-label` = "Cerrar")
          ),
          tags$div(class = "modal-body",
                   includeMarkdown("markdown/user_guide.md")),
          tags$div(class = "modal-footer",
            tags$button(type = "button", class = "btn btn-primary",
              `data-bs-dismiss` = "modal", "Cerrar"))
        )
      )
    ),
    tags$div(
      class = "modal fade", id = "personaNotesModal", tabindex = "-1",
      `aria-labelledby` = "personaNotesLabel", `aria-hidden` = "true",
      tags$div(class = "modal-dialog modal-lg modal-dialog-scrollable",
        tags$div(class = "modal-content",
          tags$div(class = "modal-header",
            tags$h5(class = "modal-title", id = "personaNotesLabel",
                    "Novedades"),
            tags$button(type = "button", class = "btn-close",
              `data-bs-dismiss` = "modal", `aria-label` = "Cerrar")
          ),
          tags$div(class = "modal-body",
                   includeMarkdown("markdown/release_notes.md")),
          tags$div(class = "modal-footer",
            tags$button(type = "button", class = "btn btn-primary",
              `data-bs-dismiss` = "modal", "Cerrar"))
        )
      )
    ),

    # JavaScript for persona clicks
    tags$script(HTML("
      $(document).on('click', '.persona-card-item', function(e) {
        if ($(e.target).hasClass('example-chip')) return;
        var persona = $(this).data('persona');
        Shiny.setInputValue('select_persona', persona, {priority: 'event'});
      });

      $(document).on('keydown', '.persona-card-item', function(e) {
        if (e.key === 'Enter' || e.key === ' ') {
          e.preventDefault();
          var persona = $(this).data('persona');
          Shiny.setInputValue('select_persona', persona, {priority: 'event'});
        }
      });

      $(document).on('click', '.example-chip', function(e) {
        e.stopPropagation();
        var persona = $(this).closest('.persona-card-item').data('persona');
        var prompt = $(this).data('prompt');
        Shiny.setInputValue('select_persona_with_prompt', {
          persona: persona, prompt: prompt, nonce: Math.random()
        }, {priority: 'event'});
      });
    "))
  )
}

# ---- Chat View ----
chat_ui_view <- function(persona_id = "general") {
  p <- get_persona(persona_id)

  tagList(
    page_sidebar(
      title = tags$span(
        class = "navbar-brand-custom",
        tags$img(
          src = "mia-logo.svg",
          alt = "MIA",
          width = "32",
          height = "32",
          class = "mia-navbar-logo"
        ),
        "MIA ",
        tags$span(style = "font-weight: 400; font-size: 0.8em; opacity: 0.7;",
                  "- Tu asistente educativo")
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
          "Modelo de IA:",
          choices = list(
            "GPT-4 (Mejor calidad)" = "gpt-4.1",
            "GPT-5.1 (Mejor razonamiento)" = "gpt-5.1"
          ),
          selected = "gpt-4.1"
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
        downloadButton("download_chat", "Descargar historial",
                       class = "btn-primary", style = "width: 100%;")
      ),

      # ---- Main Content ----
      card(
        id = "main-content-panel",
        class = "border-0 bg-transparent",

        # Help buttons + dark mode toggle top-right
        tags$div(
          class = "help-buttons-container",
          actionButton(
            "btn_user_guide", label = NULL, icon = icon("book"),
            class = "btn-outline-primary btn-sm",
            title = "Gu\u00eda de usuario",
            `data-bs-toggle` = "modal", `data-bs-target` = "#userGuideModal"
          ),
          actionButton(
            "btn_release_notes", label = NULL, icon = icon("clipboard-list"),
            class = "btn-outline-primary btn-sm",
            title = "Novedades",
            `data-bs-toggle` = "modal", `data-bs-target` = "#releaseNotesModal"
          ),
          input_dark_mode(id = "dark_mode", mode = "light")
        ),

        # Persona indicator bar
        tags$div(
          class = "persona-indicator",
          tags$div(
            class = "persona-indicator-info",
            tags$span(
              class = "persona-indicator-icon",
              style = paste0("background-color: ", p$color, ";"),
              icon(p$icon)
            ),
            tags$span(class = "persona-indicator-name", p$name)
          ),
          actionButton("change_persona", "Cambiar",
                       class = "btn-sm btn-outline-primary",
                       icon = icon("exchange-alt"))
        ),

        # Message counter
        tags$div(
          id = "message-counter",
          class = "message-counter"
        ),

        # Chat UI
        card_body(chat_ui("chat")),

        # Status
        tags$div(
          id = "chat-status-container",
          tags$div(id = "chat_status")
        ),

        # Input controls (Speak + Attach)
        tags$div(
          class = "input-controls-container",
          actionButton("btn_speech", "Hablar",
                       icon = icon("microphone"),
                       class = "btn-primary btn-sm",
                       title = "Dictar mensaje",
                       `aria-label` = "Dictar mensaje por voz"),
          actionButton("btn_camera", "Adjuntar",
                       icon = icon("paperclip"),
                       class = "btn-primary btn-sm",
                       title = "Subir archivo o foto",
                       `aria-label` = "Adjuntar archivo")
        ),

        div(class = "bottom-spacer", style = "height: 80px;"),

        # Footer
        tags$footer(
          tags$div(
            class = "footer-content",
            tags$span(class = "footer-left", "MIA v2.0"),
            tags$span(class = "footer-right", "Created by Alexis Roldan - 2025")
          ),
          class = "app-footer"
        ),

        # FAB: New chat
        tags$div(
          class = "floating-action-container",
          actionButton(
            inputId = "new_chat", label = NULL,
            icon = icon("comments"),
            class = "btn-primary btn-lg new-chat-button",
            `aria-label` = "Nuevo chat"
          ),
          tags$div("Nuevo chat", class = "new-chat-label")
        )
      ),

      # ---- Modals ----
      tags$div(
        class = "modal fade", id = "userGuideModal", tabindex = "-1",
        `aria-labelledby` = "userGuideLabel", `aria-hidden` = "true",
        tags$div(class = "modal-dialog modal-lg modal-dialog-scrollable",
          tags$div(class = "modal-content",
            tags$div(class = "modal-header",
              tags$h5(class = "modal-title", id = "userGuideLabel",
                      "Gu\u00eda de Usuario"),
              tags$button(type = "button", class = "btn-close",
                `data-bs-dismiss` = "modal", `aria-label` = "Cerrar")
            ),
            tags$div(class = "modal-body",
                     includeMarkdown("markdown/user_guide.md")),
            tags$div(class = "modal-footer",
              tags$button(type = "button", class = "btn btn-primary",
                `data-bs-dismiss` = "modal", "Cerrar"))
          )
        )
      ),
      tags$div(
        class = "modal fade", id = "releaseNotesModal", tabindex = "-1",
        `aria-labelledby` = "releaseNotesLabel", `aria-hidden` = "true",
        tags$div(class = "modal-dialog modal-lg modal-dialog-scrollable",
          tags$div(class = "modal-content",
            tags$div(class = "modal-header",
              tags$h5(class = "modal-title", id = "releaseNotesLabel",
                      "Novedades"),
              tags$button(type = "button", class = "btn-close",
                `data-bs-dismiss` = "modal", `aria-label` = "Cerrar")
            ),
            tags$div(class = "modal-body",
                     includeMarkdown("markdown/release_notes.md")),
            tags$div(class = "modal-footer",
              tags$button(type = "button", class = "btn btn-primary",
                `data-bs-dismiss` = "modal", "Cerrar"))
          )
        )
      )
    ),

    # ---- Chat JS ----
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
            $parent.find('.custom-file-label').text('Elegir archivo');
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
            $parent.find('.custom-file-label').text('Elegir archivo');
          }
        }, 50);
      });

      Shiny.addCustomMessageHandler('clearChatStatus', function(message) {
        $('#chat_status').html('');
      });

      Shiny.addCustomMessageHandler('enableDownloadButton', function(message) {
        $('#download_chat').prop('disabled', false).removeClass('disabled');
      });

      Shiny.addCustomMessageHandler('updateMessageCounter', function(data) {
        var $counter = $('#message-counter');
        if (!$counter.length) return;

        if (data.count >= 7) {
          $counter.addClass('visible').removeClass('counter-warning counter-limit');
          var text = data.count + '/' + data.max + ' mensajes en esta conversaci\\u00f3n';

          if (data.count >= data.max) {
            $counter.addClass('counter-limit');
            text += ' \\u2014 L\\u00edmite alcanzado. Inicia un nuevo chat.';
          } else if (data.count >= 9) {
            $counter.addClass('counter-warning');
            text += ' \\u2014 Cerca del l\\u00edmite';
          }

          $counter.text(text);
        } else {
          $counter.removeClass('visible counter-warning counter-limit');
        }
      });
    ")
  )
}
