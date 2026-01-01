# MIA - Multimodal Intelligent Assistant 🤖✨📚

User Guide

Welcome to **MIA**, your personal AI-powered learning assistant!

## 💾 How to Save Your Conversations

**Why Download Your Chat History?**
- 📚 **Review Later**: Keep helpful explanations for exam preparation
- 👨‍👩‍👧 **Share with Others**: Send to teachers, parents, or study partners
- 📝 **Build Your Notes**: Create a personal library of learning resources
- 🔄 **Track Progress**: See how much you've learned over time

**How to Download:**
1. Look for the **"Download History"** button in the sidebar (left side on desktop, menu on mobile)
2. Click the button after you've finished your conversation
3. Wait a moment while MIA prepares your file
4. A formatted HTML file will download to your device
5. Open the file in any web browser to read your complete conversation

**What's Included:**
- ✅ All your questions and prompts
- ✅ Complete AI responses with explanations
- ✅ Nicely formatted text that's easy to read
- ✅ Timestamp of when the conversation was saved

**Tips:**
- Download important conversations right away - don't wait!
- Give your downloaded files descriptive names (like "Math_Homework_Dec31.html")
- You can open these files anytime, even without internet

---

## 🎤 How to Talk to MIA (Speech-to-Text)

**Perfect for when you're:**
- 👩‍🍳 Cooking and can't type
- 🚗 Driving (safely parked!)
- 🤱 Holding a baby
- 📝 Have lots to say

**How to Use:**
1. **Click the Red Microphone Button** (🎤) below the chat box
2. **Start Speaking** - Talk naturally, like you're asking a friend
3. **Pause When Done** - MIA will automatically stop listening after 3 seconds of silence
4. **Review Your Words** - Your speech appears as text in the chat box
5. **Edit if Needed** - Fix any mistakes before sending
6. **Send Your Message** - Press Enter or click Send

**Tips for Best Results:**
- Speak clearly and at a normal pace
- Find a quiet place with less background noise
- Say "comma" or "period" for punctuation (though MIA is smart and often adds it automatically!)
- If it doesn't catch everything, just edit the text before sending

## 📸 How to Share Images with MIA

**What Can You Share?**
- 📐 Math problems and equations
- 🔬 Science diagrams and lab results
- 📖 Textbook pages or handouts
- ✏️ Your handwritten notes
- 🎨 Art projects for feedback
- 📊 Charts and graphs to analyze

**Two Easy Ways to Upload:**

### Method 1: Camera/Paperclip Button (Quickest!)
1. Click the **📎 Attach** button below the chat
2. **On Mobile**: Choose "Take Photo" or "Photo Library"
3. **On Computer**: Select files from your folders
4. Snap or select your images
5. They appear in the chat - ready to discuss!

### Method 2: Sidebar Upload
1. Look at the left sidebar (or menu on mobile)
2. Find the **"Attach image(s)"** section
3. Click to select from your device
4. Your images show up with preview thumbnails

### 🎯 Pro Tips for Multiple Images

**When to Upload Multiple Photos:**
- ✅ Multi-step math problems (one image per step)
- ✅ Front and back of a worksheet
- ✅ Different angles of a science project
- ✅ Series of textbook pages

**How MIA Handles Them:**
- Looks at ALL your images together
- Understands the relationship between them
- Gives you one complete answer that covers everything
- Can reference specific images ("In your second photo...")

## 📄 How to Upload Documents

**What Documents Can MIA Read?**
- 📕 **PDFs**: Textbooks, articles, study guides, forms
- 📘 **Word Files (.docx)**: Essays, reports, assignments
- 📊 **Excel/Spreadsheets (.xlsx, .xls)**: Data tables, grades, budgets
- 📋 **CSV Files**: Raw data and lists

**How It Works:**
1. **Click Attach** or use the sidebar upload
2. **Select Your Document** from your device
3. **MIA Reads It Automatically** - extracts all the text
4. **Ask Questions** about the content
   - "Summarize this article"
   - "Explain the data in this spreadsheet"
   - "Help me understand page 5"

**What About Scanned Documents?**
- If your PDF is a scan (like a photo of a page), MIA might not be able to read the text
- In that case, MIA will let you know and suggest uploading it as an image instead
- Or you can summarize the key parts yourself

**Privacy Note:**
- Your documents are only used for your current conversation
- They're not stored permanently or shared with others
- Start a "New Chat" to clear everything and start fresh

## 🖼️ File Previews
- **Images**: Thumbnails appear in the sidebar with filename, file size, and basic dimensions when available.
- **Documents**: Non-image files show a compact preview (filename and icon) and are listed under attachments so you can confirm what was uploaded.

## 🌐 Getting Current Information (Web Search)

**When Does MIA Search the Web?**

MIA is smart and knows when information might be out of date. She can search the internet when you need:
- 📰 **Current Events**: Latest news or recent developments
- 📊 **Up-to-date Statistics**: Recent data and numbers
- 🔬 **New Research**: Latest scientific findings
- 💡 **Trending Topics**: What's happening right now

**How It Works:**
- You don't need to do anything special!
- Just ask your question normally
- MIA decides if web search would help
- She finds reliable sources and summarizes the information
- You get accurate, current answers

**Example Questions:**
- "What's the current population of Brazil?"
- "What are the latest recommendations for child nutrition?"
- "Find recent articles about learning strategies"
- "What's new in renewable energy technology?"

**Trust & Safety:**
- MIA uses Google Custom Search
- Only searches reliable, appropriate sources
- Results are filtered for quality
- Perfect for homework and research

---

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


## 💬 Having a Conversation with MIA

**The Basics:**
1. **Type Your Question or Request** in the chat box at the bottom
2. **Press Enter** or click the **Send** button
3. **Watch MIA Think** - you'll see a "brain" icon while she's working
4. **Read the Response** - answers appear in real-time, word by word
5. **Ask Follow-ups** - MIA remembers what you've talked about!

**Starting Fresh:**
- See the **floating "+" button** (usually bottom-right corner)?
- Click it anytime to start a **New Chat**
- This clears the history and gives you a clean slate
- Great for switching topics or starting a new homework session

**MIA Remembers:**
- ✅ Previous questions in the same chat
- ✅ Images you've shared
- ✅ Context from earlier in your conversation
- ✅ Your learning preferences and style
- ❌ NOT conversations from other chats (they're private!)

---

## ⚙️ Settings & Customization (In the Sidebar)

**Finding the Settings:**
- **Desktop**: Look at the left sidebar
- **Mobile**: Tap the menu icon (≡) at the top

### 🤖 Intelligence Level

Choose how "smart" you want MIA to be:

- **GPT-4 (Standard)**: Perfect for most questions
  - Fast responses
  - Great for homework help
  - Good for everyday questions

- **GPT-5.1 (Best Reasoning & Coding)**: Use for tough problems
  - Deeper thinking
  - Complex math and science
  - Advanced coding help
  - More detailed explanations

**When to Switch:**
- Start with GPT-4 for normal questions
- Switch to GPT-5.1 if you need more detailed help
- You can change this anytime!

### 🎯 I Need Help With... (Choose Your Assistant)

Pick the type of help you need:

- **General**: Everyday questions and learning
- **R Code Helper**: Programming in R language
- **Python Code Helper**: Programming in Python
- **SQL Code Helper**: Database and data queries
- **Mother Assistant** 👩‍👧: Parenting advice, child development, activity ideas
- **Elementary School Tutor** (Spanish): For young learners
- **High School Prep** (Spanish): University entrance exam prep
- **Small Business Helper** (Spanish): Business advice
- **Government Forms Helper** (Peru): Help with bureaucracy
- **English for Graduation** (Spanish): University English certification

**How This Helps:**
- Each mode gives MIA special knowledge
- She adjusts her teaching style
- Provides more relevant examples
- Uses appropriate vocabulary

---

## 🎓 Tips for Best Results

### For Students:
- 📸 **Take Clear Photos**: Good lighting, steady hand
- ❓ **Ask Specific Questions**: "How do I solve this equation?" is better than "Help"
- 📝 **Include Context**: "I'm in 8th grade" or "This is for my chemistry class"
- 💬 **Ask Follow-ups**: "Can you explain that differently?" or "Show me another example"
- 💾 **Download Important Chats**: Save helpful explanations for exam review

### For Parents:
- 🎯 **Use Mother Assistant Mode**: Specialized for parenting questions
- 🎤 **Try Voice Input**: Perfect when your hands are full
- 📋 **Save Advice**: Download conversations about sleep schedules, discipline tips, etc.
- 🔄 **Ask Variations**: "My 3-year-old won't eat vegetables" gets specific, practical help
- 📚 **Build Your Library**: Keep helpful conversations organized by topic

### For Everyone:
- ⏰ **Be Patient**: Better to wait for a complete, thoughtful answer
- 🔄 **Rephrase if Needed**: Try asking your question a different way
- 🎯 **Be Specific**: More details = better answers
- 💡 **Experiment**: Try different modes and intelligence levels
- 📱 **Use on Any Device**: Works great on phone, tablet, or computer

---

## 🆘 Need More Help?

**Having Issues?**
- Try refreshing your browser
- Check your internet connection
- Make sure images are clear and not too large
- Start a new chat if things seem stuck

**Questions or Feedback?**
- Contact the administrator using the email link at the bottom of the page
- We love hearing how MIA is helping you!
- Report any problems so we can fix them

**Remember:**
- 🤖 MIA is here to **help you learn**, not just give answers
- 💡 The best learning happens when you **engage** with the explanations
- 📚 **Download and review** your conversations to reinforce learning
- 🎯 **Practice** what you learn - MIA can create practice problems too!

---

**Happy Learning! 🎓✨**

*MIA - Your Multimodal Intelligent Assistant, always here to help you succeed!*