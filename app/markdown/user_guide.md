# Lucy - AI Assistant User Guide

Welcome to **Lucy**, your personal AI-powered learning assistant!

## 🎤 How to Use Speech-to-Text
1. **Click the Red Microphone Button** below the chat input.
2. **Speak clearly**. The assistant will listen continuously.
3. **Pause**: The microphone will automatically stop after **3 seconds of silence**.
4. Your speech will be appended to the text box. You can edit it before sending.

## 📸 How to Use Images
You have two options to send images:
1. **Attach Image Button**: Click the camera icon next to the microphone. On mobile, this lets you take a photo or choose from your library.
2. **Sidebar Upload**: Use the "Attach image(s)" file picker in the sidebar.

### Multi-Image Tips
- You can attach multiple related photos in one message (for example: several steps of a math problem or different pages of a worksheet). Lucy will analyze them together and provide an integrated response.

## 📄 Document Uploads (PDF, Word, Excel, CSV)
- **Supported types**: PDF (.pdf), Word (.docx), Excel (.xlsx/.xls) and CSV (.csv).
- **How it works**: Uploaded documents are processed automatically. For Word and PDFs, Lucy extracts text; for Excel, each sheet is converted into CSV-like text so the model can reason about the tables.
- **Scanned PDFs**: If the PDF is scanned (no extractable text), Lucy will notify you and suggest uploading a text-based PDF or summarizing key parts.
- **Privacy**: Documents are temporarily processed for the conversation and (if enabled) stored according to the app's retention policy.

## 🖼️ File Previews
- **Images**: Thumbnails appear in the sidebar with filename, file size, and basic dimensions when available.
- **Documents**: Non-image files show a compact preview (filename and icon) and are listed under attachments so you can confirm what was uploaded.

## 🔎 Web Search Tool
- Lucy can perform controlled web lookups using Google Custom Search when the administrator configures API credentials. If available, Lucy may use this to retrieve up-to-date information. This is a safe, rate-limited tool and only used when the assistant deems it helpful.

### Admin: Environment variables for Google Custom Search
If you enable the web search tool, set these environment variables (in `.Renviron` or export in your shell):

```
OPENAI_API_LUCY_SHINY=your_openai_api_key_here
google_search_api_key=your_google_api_key_here
google_search_engine_id=your_search_engine_id_here
```

- Obtain the API key from Google Cloud Console and the Search Engine ID (`cx`) from your Custom Search Engine settings.
- Restart R / the Shiny app after setting environment variables so the app picks them up.
- Note: earlier app versions used a misspelled env var (`goole_search_api_key`); the code has been corrected to `google_search_api_key`.

### Quick: Create a Google API key and Custom Search Engine
1. Open Google Cloud Console: https://console.cloud.google.com/ and create/select a project.
2. Enable **Custom Search API** (APIs & Services → Library → search "Custom Search API").
3. Create an API key (APIs & Services → Credentials → Create Credentials → API key) and set it as `google_search_api_key`.
4. Create a Custom Search Engine at https://cse.google.com/cse/ and copy the Search Engine ID (`cx`) into `google_search_engine_id`.
5. Restart the app and log in as admin to see configuration warnings if any env vars are missing.


## 💬 Chatting
- **Type your message** in the main input box.
- Press **Enter** or click **Send** to get a response.
- **New Chat**: Click the floating "+" button to clear the history and start fresh.

## ⚙️ Settings (Sidebar)
- **Theme**: Toggle between Light and Dark mode.
- **Model**: Choose between GPT-4 (smarter) and GPT-3.5 (faster).
- **Prompt Type**:
    - **General**: Standard conversation.
    - **R/Python/SQL Code**: Specialized for programming help.
    - **Agente Primaria**: Specialized Spanish agent.

## 🎓 Educational Tips
- **Homework Help**: Upload a picture of a problem and ask for a step-by-step explanation.
- **Code Help**: Select the specific code mode for better syntax highlighting and logic.

---
*Need more help? Contact the administrator via the email link in the footer.*