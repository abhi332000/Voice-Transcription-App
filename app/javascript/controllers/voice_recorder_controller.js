import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "startButton",
    "stopButton",
    "statusIndicator",
    "liveTranscription",
    "liveText",
    "finalTranscription",
    "summarySection",
    "summaryText",
    "resultsSection",
    "errorMessage",
    "loadingIndicator"
  ]

  connect() {
    this.mediaRecorder = null
    this.audioChunks = []
    this.recognition = null
    this.finalTranscript = ""
    this.interimTranscript = ""
    this.transcriptionId = null

    // Check for browser support
    if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
      this.showError("Your browser doesn't support audio recording.")
      return
    }

    // Initialize Web Speech API if available
    if ('webkitSpeechRecognition' in window || 'SpeechRecognition' in window) {
      const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition
      this.recognition = new SpeechRecognition()
      this.recognition.continuous = true
      this.recognition.interimResults = true
      this.recognition.lang = 'en-US'

      this.recognition.onresult = this.handleSpeechResult.bind(this)
      this.recognition.onerror = this.handleSpeechError.bind(this)
      this.recognition.onend = () => {
        if (this.isRecording) {
          this.recognition.start() // Restart if still recording
        }
      }
    }
  }

  async startRecording(event) {
    event.preventDefault()

    try {
      // Request microphone permission
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true })

      // Initialize MediaRecorder for audio capture
      this.mediaRecorder = new MediaRecorder(stream)
      this.audioChunks = []

      this.mediaRecorder.ondataavailable = (event) => {
        this.audioChunks.push(event.data)
      }

      this.mediaRecorder.onstop = this.handleRecordingStop.bind(this)

      // Start recording
      this.mediaRecorder.start()
      this.isRecording = true

      // Start speech recognition for live transcription
      if (this.recognition) {
        this.finalTranscript = ""
        this.interimTranscript = ""
        this.recognition.start()
      }

      // Update UI
      this.startButtonTarget.style.display = "none"
      this.stopButtonTarget.style.display = "inline-block"
      this.statusIndicatorTarget.style.display = "flex"
      this.liveTranscriptionTarget.style.display = "block"
      this.resultsSectionTarget.style.display = "none"
      this.errorMessageTarget.style.display = "none"

      console.log("Recording started...")
    } catch (error) {
      console.error("Error starting recording:", error)
      this.showError(`Error accessing microphone: ${error.message}`)
    }
  }

  stopRecording(event) {
    event.preventDefault()

    this.isRecording = false

    if (this.mediaRecorder && this.mediaRecorder.state !== "inactive") {
      this.mediaRecorder.stop()
    }

    if (this.recognition) {
      this.recognition.stop()
    }

    // Stop all audio tracks
    if (this.mediaRecorder && this.mediaRecorder.stream) {
      this.mediaRecorder.stream.getTracks().forEach(track => track.stop())
    }

    // Update UI
    this.startButtonTarget.style.display = "inline-block"
    this.stopButtonTarget.style.display = "none"
    this.statusIndicatorTarget.style.display = "none"

    console.log("Recording stopped...")
  }

  handleSpeechResult(event) {
    let interim = ""

    for (let i = event.resultIndex; i < event.results.length; i++) {
      const transcript = event.results[i][0].transcript

      if (event.results[i].isFinal) {
        this.finalTranscript += transcript + " "
      } else {
        interim += transcript
      }
    }

    this.interimTranscript = interim

    // Update live transcription display
    const displayText = this.finalTranscript + '<span class="interim">' + this.interimTranscript + '</span>'
    this.liveTextTarget.innerHTML = displayText || '<p class="placeholder">Listening...</p>'
  }

  handleSpeechError(event) {
    console.error("Speech recognition error:", event.error)
  }

  async handleRecordingStop() {
    // Show loading indicator
    this.loadingIndicatorTarget.style.display = "block"
    this.liveTranscriptionTarget.style.display = "none"

    // Create blob from audio chunks
    const audioBlob = new Blob(this.audioChunks, { type: 'audio/webm' })

    try {
      // Create FormData to send audio
      const formData = new FormData()
      formData.append('audio', audioBlob, 'recording.webm')

      // First create a transcription record
      const createResponse = await fetch('/transcriptions', {
        method: 'POST',
        headers: {
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: JSON.stringify({
          transcription: {
            content: this.finalTranscript.trim()
          }
        })
      })

      if (!createResponse.ok) {
        throw new Error('Failed to create transcription')
      }

      const transcriptionData = await createResponse.json()
      this.transcriptionId = transcriptionData.id

      // Upload audio for more accurate transcription via Whisper API
      const uploadResponse = await fetch(`/transcriptions/${this.transcriptionId}/upload_audio`, {
        method: 'POST',
        headers: {
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
          'Accept': 'application/json'
        },
        body: formData
      })

      if (!uploadResponse.ok) {
        // If Whisper API fails, use the Web Speech API transcription
        console.warn('Whisper API failed, using Web Speech API transcription')
        this.displayResults(transcriptionData)
      } else {
        const whisperData = await uploadResponse.json()
        this.displayResults(whisperData)
      }
    } catch (error) {
      console.error('Error processing recording:', error)

      // Fallback to Web Speech API transcription
      if (this.finalTranscript.trim()) {
        this.displayResults({
          id: Date.now(),
          content: this.finalTranscript.trim(),
          summary: null,
          status: 'completed'
        })
      } else {
        this.showError(`Error processing recording: ${error.message}`)
      }
    } finally {
      this.loadingIndicatorTarget.style.display = "none"
    }
  }

  displayResults(data) {
    // Display final transcription
    this.finalTranscriptionTarget.innerHTML = data.content || this.finalTranscript.trim()

    // Display summary if available
    if (data.summary) {
      this.summaryTextTarget.innerHTML = data.summary
      this.summarySectionTarget.style.display = "block"
    } else {
      this.summaryTextTarget.innerHTML = '<div class="loading">No summary available</div>'
      this.summarySectionTarget.style.display = "block"
    }

    // Show results section
    this.resultsSectionTarget.style.display = "block"
  }

  copyTranscription(event) {
    event.preventDefault()

    const text = this.finalTranscriptionTarget.textContent
    navigator.clipboard.writeText(text).then(() => {
      alert('Transcription copied to clipboard!')
    }).catch(err => {
      console.error('Failed to copy:', err)
    })
  }

  newRecording(event) {
    event.preventDefault()

    // Reset state
    this.finalTranscript = ""
    this.interimTranscript = ""
    this.audioChunks = []
    this.transcriptionId = null

    // Reset UI
    this.resultsSectionTarget.style.display = "none"
    this.liveTextTarget.innerHTML = '<p class="placeholder">Your transcription will appear here as you speak...</p>'
    this.startButtonTarget.style.display = "inline-block"
    this.errorMessageTarget.style.display = "none"
  }

  showError(message) {
    this.errorMessageTarget.textContent = message
    this.errorMessageTarget.style.display = "block"
    this.startButtonTarget.disabled = true
  }

  disconnect() {
    if (this.recognition) {
      this.recognition.stop()
    }

    if (this.mediaRecorder && this.mediaRecorder.state !== "inactive") {
      this.mediaRecorder.stop()
    }
  }
}

