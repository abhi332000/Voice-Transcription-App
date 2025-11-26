class Transcription < ApplicationRecord
  validates :status, inclusion: { in: %w[processing completed failed] }

  # Generate summary using OpenAI API
  def generate_summary
    return if content.blank?

    begin
      client = OpenAI::Client.new
      response = client.chat(
        parameters: {
          model: "gpt-3.5-turbo",
          messages: [
            {
              role: "system",
              content: "You are a helpful assistant that creates concise summaries of conversations. Keep summaries to 2-3 sentences highlighting the key points."
            },
            {
              role: "user",
              content: "Please summarize the following transcription:\n\n#{content}"
            }
          ],
          temperature: 0.7,
          max_tokens: 150
        }
      )

      self.summary = response.dig("choices", 0, "message", "content")
      self.status = "completed"
      save!
    rescue => e
      self.status = "failed"
      self.metadata = (metadata || {}).merge(error: e.message)
      save!
      raise e
    end
  end
end

