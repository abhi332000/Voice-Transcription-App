require 'rails_helper'

RSpec.describe Transcription, type: :model do
  describe 'validations' do
    it 'validates status inclusion' do
      transcription = Transcription.new(status: 'invalid_status')
      expect(transcription).not_to be_valid
      expect(transcription.errors[:status]).to include('is not included in the list')
    end

    it 'accepts valid status values' do
      %w[processing completed failed].each do |status|
        transcription = Transcription.new(status: status)
        expect(transcription.valid?).to be(true), "Expected #{status} to be valid"
      end
    end
  end

  describe '#generate_summary' do
    let(:transcription) { Transcription.create!(content: 'This is a test transcription.', status: 'processing') }
    let(:mock_client) { instance_double(OpenAI::Client) }
    let(:mock_response) do
      {
        'choices' => [
          {
            'message' => {
              'content' => 'This is a summary of the transcription.'
            }
          }
        ]
      }
    end

    before do
      allow(OpenAI::Client).to receive(:new).and_return(mock_client)
    end

    context 'when OpenAI API call is successful' do
      before do
        allow(mock_client).to receive(:chat).and_return(mock_response)
      end

      it 'generates a summary and updates the transcription' do
        transcription.generate_summary

        expect(transcription.reload.summary).to eq('This is a summary of the transcription.')
        expect(transcription.status).to eq('completed')
      end

      it 'calls OpenAI API with correct parameters' do
        expect(mock_client).to receive(:chat).with(
          parameters: {
            model: 'gpt-3.5-turbo',
            messages: [
              {
                role: 'system',
                content: 'You are a helpful assistant that creates concise summaries of conversations. Keep summaries to 2-3 sentences highlighting the key points.'
              },
              {
                role: 'user',
                content: "Please summarize the following transcription:\n\nThis is a test transcription."
              }
            ],
            temperature: 0.7,
            max_tokens: 150
          }
        ).and_return(mock_response)

        transcription.generate_summary
      end
    end

    context 'when content is blank' do
      it 'does not call OpenAI API' do
        blank_transcription = Transcription.create!(content: '', status: 'processing')
        expect(mock_client).not_to receive(:chat)

        blank_transcription.generate_summary
      end
    end

    context 'when OpenAI API call fails' do
      before do
        allow(mock_client).to receive(:chat).and_raise(StandardError.new('API Error'))
      end

      it 'sets status to failed and stores error in metadata' do
        expect { transcription.generate_summary }.to raise_error(StandardError, 'API Error')

        expect(transcription.reload.status).to eq('failed')
        expect(transcription.metadata['error']).to eq('API Error')
      end
    end
  end
end

