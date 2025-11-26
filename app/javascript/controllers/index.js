// Load and register all controllers
import { application } from "controllers/application"
import VoiceRecorderController from "controllers/voice_recorder_controller"

// Register voice recorder controller
application.register("voice-recorder", VoiceRecorderController)
