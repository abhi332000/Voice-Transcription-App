class TranscriptionsController < ApplicationController
  before_action :set_transcription, only: [:show, :summary, :upload_audio]

  def index
    @transcriptions = Transcription.order(created_at: :desc).limit(10)
  end

  def new
    @transcription = Transcription.new
  end

  def create
    @transcription = Transcription.new(transcription_params)

    if @transcription.save
      # Generate summary asynchronously in background (simplified for demo)
      @transcription.generate_summary if @transcription.content.present?

      render json: {
        id: @transcription.id,
        content: @transcription.content,
        summary: @transcription.summary,
        status: @transcription.status
      }
    else
      render json: { errors: @transcription.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: @transcription }
    end
  end

  def summary
    if @transcription.summary.blank?
      @transcription.generate_summary
    end

    render json: {
      id: @transcription.id,
      summary: @transcription.summary,
      status: @transcription.status
    }
  end

  def upload_audio
    audio_data = params[:audio]

    if audio_data.blank?
      render json: { error: "No audio data provided" }, status: :unprocessable_entity
      return
    end

    begin
      # Transcribe audio using OpenAI Whisper API
      client = OpenAI::Client.new

      # Create a temporary file for the audio
      temp_file = Tempfile.new(['audio', '.webm'])
      temp_file.binmode

      # Decode base64 audio data if provided
      if audio_data.is_a?(String) && audio_data.include?('base64')
        audio_binary = Base64.decode64(audio_data.split(',')[1])
        temp_file.write(audio_binary)
      else
        temp_file.write(audio_data.read)
      end

      temp_file.rewind

      # Call Whisper API
      response = client.audio.transcribe(
        parameters: {
          model: "whisper-1",
          file: temp_file
        }
      )

      transcription_text = response["text"]

      # Update transcription with content
      @transcription.update(content: transcription_text)

      # Generate summary
      @transcription.generate_summary

      render json: {
        id: @transcription.id,
        content: @transcription.content,
        summary: @transcription.summary,
        status: @transcription.status
      }
    rescue => e
      render json: { error: e.message }, status: :internal_server_error
    ensure
      temp_file.close
      temp_file.unlink
    end
  end

  private

  def set_transcription
    @transcription = Transcription.find(params[:id])
  end

  def transcription_params
    params.require(:transcription).permit(:content)
  end
end

