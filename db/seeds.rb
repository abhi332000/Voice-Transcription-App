# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create sample transcriptions for demonstration
puts "Creating sample transcriptions..."

Transcription.create!(
  content: "Welcome to the voice transcription demo. This is a sample transcription that shows how the app works. " \
           "You can record your voice, see real-time transcription, and get AI-powered summaries automatically.",
  summary: "Introduction to voice transcription demo with features including voice recording, real-time transcription, and AI summaries.",
  status: "completed",
  created_at: 2.days.ago
)

Transcription.create!(
  content: "This application uses OpenAI's Whisper API for speech-to-text conversion and GPT-3.5 for generating summaries. " \
           "The frontend is built with StimulusJS which provides a reactive, yet simple approach to handling user interactions. " \
           "The Web Speech API enables real-time transcription as you speak.",
  summary: "Technical overview of the app using OpenAI Whisper, GPT-3.5, StimulusJS, and Web Speech API for transcription and summarization.",
  status: "completed",
  created_at: 1.day.ago
)

Transcription.create!(
  content: "The interface is clean and modern with a purple gradient theme. " \
           "Users can click a button to start recording, see their words appear in real-time, " \
           "and then receive a polished transcription with a summary when they're done. " \
           "All past transcriptions are stored in the database and can be viewed from the home page.",
  summary: "Description of the user interface featuring purple gradient design, recording functionality, real-time feedback, and transcription history.",
  status: "completed",
  created_at: 12.hours.ago
)

puts "✓ Created #{Transcription.count} sample transcriptions"
puts "🎉 Seed data loaded successfully!"

