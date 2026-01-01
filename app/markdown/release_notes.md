# Release Notes

## Version 1.3.2 (January 2026)

### 🎉 New Features
- **Complete Chat History Download**: Download your full conversation history as a beautifully formatted HTML file
  - Perfect for reviewing your learning progress
  - Share with teachers or study partners
  - Keep important explanations for future reference
  - Works great for documenting homework help sessions

### ⚡ Performance & Memory Optimization
- **Smart Image Compression**: Automatically resizes and compresses uploaded images to ~10% of original size
  - Images optimized to 1024px max width with 80% JPEG quality
  - Reduces memory usage by ~90% during image processing
  - Faster upload and processing times
- **Conversation History Management**: Keeps last 10 messages in active memory for optimal performance
  - Prevents memory bloat during long conversations
  - Maintains sufficient context for follow-up questions
  - Configurable limit (developers can adjust in `global.R`)
- **File Size Validation**: 10MB upload limit per file to prevent memory issues
  - Clear error messages when files exceed limit
  - Configurable threshold for different deployment environments
  - Protects against out-of-memory crashes
- **Optimized Cloud Deployment**: Significant improvements for free-tier hosting platforms
  - Works smoothly on shinyapps.io free tier (1GB RAM)
  - Single base64 encoding per image (eliminates redundant processing)
  - Reduced memory footprint by ~90% overall

### 🐛 Bug Fixes & Improvements
- **Fixed Assistant Response Saving**: Chat downloads now include complete AI responses, not just your questions
- **Optimized Timing**: Added smart 40-second capture window to ensure long, detailed responses are fully saved
- **Better Memory Management**: Improved how conversations are stored and tracked
- **Reliable Exports**: Enhanced HTML generation with proper formatting and styling
- **Stable Long Sessions**: No more crashes during extended conversations with multiple images

### 💡 What This Means for You
- **Students**: Save complete homework help sessions to review before exams, upload multiple photos without slowdown
- **Parents**: Keep parenting advice and child development tips for easy reference, use voice + images smoothly
- **Teachers**: Document example interactions for your students, handle multiple student images reliably
- **Everyone**: Build your personal knowledge library with stable, fast performance even with large files

### 🔧 Technical Details (for Developers)
- **magick Package Integration**: Image processing with `image_resize()` and `image_convert()`
- **Configurable Limits**: `MAX_FILE_SIZE_MB` and `MAX_CONVERSATION_HISTORY` in `global.R`
- **Memory-Efficient Design**: Automatic trimming of conversation arrays, single-pass encoding
- **Deployment Ready**: Optimized for constrained environments (1GB RAM minimum)

---

## Version 1.3.1 (December 2025)

### 🎉 New Features
- **Chat History Download**: Download your full conversation history as a formatted HTML file with markdown rendering
- **Manual Conversation Tracking**: Improved conversation history management for more reliable exports
- **Robot Favicon**: Added friendly robot emoji (🤖) as browser tab icon

### 🐛 Bug Fixes
- Fixed corrupt chat history downloads that previously showed "No messages yet"
- Fixed issue where Speak and Attach buttons were hidden behind footer after multiple messages
- Improved button z-index and spacing for better visibility

### 🔧 Improvements
- Enhanced message storage system for better download reliability
- Improved HTML export with proper CSS styling and markdown formatting

---

## Version 1.2.2 (November 2025)

### 🎤 Speech & Media Features
- **Speech-to-Text**: Browser-based dictation via microphone button with automatic language detection
- **Camera & Multi-Image Input**: Attach multiple photos (or take pictures on mobile) in a single message
- **Document Ingestion**: Upload PDF, Word (.docx), Excel (.xlsx/.xls) and CSV files with automatic text extraction
- **Improved Previews**: Inline previews for uploaded images with filename, size, and dimensions

### 🔍 Advanced Capabilities
- **Safe Web Search Tool**: Integrated Google Custom Search for controlled web lookups when needed
- **Admin Environment Checker**: Automatic validation of required environment variables with UI warnings
- **Configuration Test Script**: Helper script to validate Google Custom Search credentials

### 🎨 User Experience
- Enhanced multimodal workflows (audio + images + documents)
- Better file handling for homework, lab reports, and document-driven tasks
- Improved error messaging and admin diagnostics

---

## Version 1.2.0 (October 2025)

### 🎓 Educational Features
- Specialized modes for different learning contexts
- Pre-University support for UNI/San Marcos entrance exams (Peru)
- MYPE business assistant for small businesses
- English certification preparation (B1/B2 level)
- Bureaucracy guide for SUNAT, RENIEC, and municipal procedures

### 💼 Core Improvements
- Enhanced conversation context management
- Improved system prompts for specialized tasks
- Better mobile responsiveness
- Dark/Light theme support

---

*For more details about Lucy's features and capabilities, please refer to the [User Guide](user_guide.md) or visit our [GitHub repository](https://github.com/roldanalex/Personal-Assistant-AI).*
