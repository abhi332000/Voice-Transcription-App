# Voice-Transcription-App
# 🎤 Voice Transcription & Summarization Web App

A Ruby on Rails 7 application that allows users to record their voice, see real-time transcription, and generate AI-powered summaries of conversations using OpenAI's Whisper and GPT models.

## ✨ Features

- **Real-time Voice Recording**: Click a button to start recording audio from your microphone
- **Live Transcription**: See your words appear on screen as you speak using Web Speech API
- **Accurate Transcription**: Audio is processed through OpenAI's Whisper API for high-quality transcription
- **AI-Powered Summaries**: Automatic conversation summarization using GPT-3.5-turbo
- **Modern UI**: Beautiful, responsive interface built with vanilla JavaScript and StimulusJS
- **Conversation History**: View and manage all your past transcriptions
- **Copy to Clipboard**: Easy copying of transcriptions for use elsewhere

## 🛠 Tech Stack

- **Backend**: Ruby on Rails 7.1
- **Frontend**: StimulusJS, Web Speech API, MediaRecorder API
- **Database**: SQLite3
- **APIs**:
  - OpenAI Whisper API (Speech-to-Text)
  - OpenAI GPT-3.5-turbo (Summarization)
- **Testing**: RSpec, FactoryBot, WebMock
- **Styling**: Custom CSS with modern gradients and animations

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- Ruby 3.2.0 or higher
- Rails 7.1.0 or higher
- SQLite3
- Bundler
- OpenAI API Key

## 🚀 Installation & Setup

### 1. Clone the Repository

```bash
cd voice-transcription-app
```

### 2. Install Dependencies

```bash
bundle install
```

### 3. Set Up Environment Variables

Create a `.env` file in the root directory:

```bash
cp .env.example .env
```

Add your OpenAI API key to the `.env` file:

```
OPENAI_API_KEY=your_openai_api_key_here
```

**To get an OpenAI API key:**
1. Visit [https://platform.openai.com/signup](https://platform.openai.com/signup)
2. Create an account or sign in
3. Navigate to [API Keys](https://platform.openai.com/api-keys)
4. Click "Create new secret key"
5. Copy the key and add it to your `.env` file

### 4. Set Up the Database

```bash
bin/rails db:create
bin/rails db:migrate
```

### 5. Start the Rails Server

```bash
bin/rails server
```

The application will be available at `http://localhost:3000`

## 🧪 Running Tests

This project includes comprehensive test coverage using RSpec.

### Run All Tests

```bash
bundle exec rspec
```

### Run Specific Test Files

```bash
# Model tests
bundle exec rspec spec/models/transcription_spec.rb

# Controller tests
bundle exec rspec spec/controllers/transcriptions_controller_spec.rb
```

### Run Tests with Coverage

```bash
COVERAGE=true bundle exec rspec
```

## 📱 Usage

### Creating a New Transcription

1. Navigate to `http://localhost:3000/transcribe`
2. Click the **"Start Listening"** button
3. Grant microphone permissions when prompted
4. Speak clearly into your microphone
5. Watch as your words appear in real-time
6. Click **"Stop Listening"** when finished
7. Wait for the final transcription and summary to be generated

### Viewing Past Transcriptions

1. Navigate to the home page at `http://localhost:3000`
2. Browse your recent transcriptions
3. Click "View Details" to see the full transcription and summary

### Features in Action

- **Live Transcription**: Uses Web Speech API for instant feedback
- **Audio Recording**: Captures high-quality audio using MediaRecorder API
- **Whisper Processing**: Sends audio to OpenAI Whisper for accurate transcription
- **Summary Generation**: Automatically creates concise summaries using GPT-3.5

## 🏗 Project Structure

```
voice-transcription-app/
├── app/
│   ├── controllers/
│   │   └── transcriptions_controller.rb    # Main controller
│   ├── models/
│   │   └── transcription.rb                # Transcription model with summarization
│   ├── views/
│   │   ├── layouts/
│   │   │   └── application.html.erb        # Main layout
│   │   └── transcriptions/
│   │       ├── index.html.erb              # Transcriptions list
│   │       ├── new.html.erb                # Recording interface
│   │       └── show.html.erb               # Transcription details
│   ├── javascript/
│   │   └── controllers/
│   │       └── voice_recorder_controller.js # StimulusJS controller
│   └── assets/
│       └── stylesheets/
│           └── application.css              # Custom styles
├── config/
│   ├── routes.rb                            # Application routes
│   └── initializers/
│       └── openai.rb                        # OpenAI configuration
├── db/
│   └── migrate/
│       └── *_create_transcriptions.rb       # Database migration
├── spec/
│   ├── models/
│   │   └── transcription_spec.rb            # Model tests
│   ├── controllers/
│   │   └── transcriptions_controller_spec.rb # Controller tests
│   └── factories/
│       └── transcriptions.rb                # Test factories
└── README.md
```

## 🔧 API Endpoints

### Transcriptions

- `GET /` - List all transcriptions (home page)
- `GET /transcribe` - New transcription recording page
- `POST /transcriptions` - Create a new transcription
- `GET /transcriptions/:id` - Show transcription details
- `GET /transcriptions/:id/summary` - Get or generate summary
- `POST /transcriptions/:id/upload_audio` - Upload and transcribe audio

## 🌐 Browser Compatibility

This application requires browsers that support:

- **Web Speech API** (Chrome, Edge, Safari)
- **MediaRecorder API** (Chrome, Firefox, Edge, Safari 14.1+)
- **ES6+ JavaScript**

### Recommended Browsers

- Chrome 25+ (best support)
- Edge 79+
- Safari 14.1+
- Firefox 25+ (no speech recognition)

## 🔐 Security Considerations

1. **API Keys**: Never commit your `.env` file or expose API keys
2. **HTTPS**: Use HTTPS in production for microphone access
3. **Rate Limiting**: Consider adding rate limiting for API calls
4. **Authentication**: Add user authentication for production use

## 🎨 Customization

### Changing the Summary Style

Edit `app/models/transcription.rb` to customize the summary prompt:

```ruby
{
  role: "system",
  content: "Your custom summary instructions here"
}
```

### Styling

Modify `app/assets/stylesheets/application.css` to customize the appearance.

### Transcription Language

Update the language in `voice_recorder_controller.js`:

```javascript
this.recognition.lang = 'en-US' // Change to your preferred language
```

## 🐛 Troubleshooting

### Microphone Not Working

- Ensure you've granted microphone permissions
- Check that your browser supports the MediaRecorder API
- Verify you're using HTTPS (required for mic access in production)

### OpenAI API Errors

- Verify your API key is correct in `.env`
- Check your OpenAI account has available credits
- Review rate limits on your OpenAI account

### Tests Failing

- Ensure all gems are installed: `bundle install`
- Reset the test database: `bin/rails db:test:prepare`
- Check that WebMock is properly configured

## 🚢 Deployment

### Heroku Deployment

```bash
# Create Heroku app
heroku create your-app-name

# Set environment variables
heroku config:set OPENAI_API_KEY=your_key_here

# Deploy
git push heroku main

# Run migrations
heroku run rails db:migrate
```

### Environment Variables for Production

- `OPENAI_API_KEY`: Your OpenAI API key
- `RAILS_MASTER_KEY`: Rails credentials master key
- `RAILS_ENV`: Set to `production`

## 📝 Future Enhancements

- [ ] Speaker diarization (multiple speakers)
- [ ] Support for multiple languages
- [ ] Audio file upload (in addition to live recording)
- [ ] User authentication and accounts
- [ ] Export transcriptions as PDF/DOCX
- [ ] Websocket-based real-time streaming
- [ ] Custom vocabulary support
- [ ] Integration with other LLM providers

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 👏 Acknowledgments

- OpenAI for Whisper and GPT APIs
- Rails community for excellent documentation
- Stimulus team for the reactive framework

## 📧 Contact

For questions or feedback, please open an issue on GitHub.

---

**Built with ❤️ using Rails 7 + StimulusJS + OpenAI**

