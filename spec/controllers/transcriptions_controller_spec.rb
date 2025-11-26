require 'rails_helper'

RSpec.describe TranscriptionsController, type: :controller do
  describe 'GET #index' do
    it 'returns a successful response' do
      get :index
      expect(response).to be_successful
    end

    it 'loads recent transcriptions' do
      transcription1 = Transcription.create!(content: 'Test 1', status: 'completed')
      transcription2 = Transcription.create!(content: 'Test 2', status: 'completed')

      get :index
      expect(assigns(:transcriptions)).to include(transcription1, transcription2)
    end
  end

  describe 'GET #new' do
    it 'returns a successful response' do
      get :new
      expect(response).to be_successful
    end

    it 'assigns a new transcription' do
      get :new
      expect(assigns(:transcription)).to be_a_new(Transcription)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_params) { { transcription: { content: 'Test transcription content' } } }
      let(:mock_transcription) { instance_double(Transcription, id: 1, content: 'Test transcription content', summary: 'Test summary', status: 'completed', save: true, generate_summary: true) }

      before do
        allow(Transcription).to receive(:new).and_return(mock_transcription)
        allow(mock_transcription).to receive(:content).and_return('Test transcription content')
      end

      it 'creates a new transcription' do
        post :create, params: valid_params, format: :json
        expect(response).to be_successful
      end

      it 'returns JSON with transcription data' do
        post :create, params: valid_params, format: :json
        json_response = JSON.parse(response.body)

        expect(json_response['id']).to eq(1)
        expect(json_response['content']).to eq('Test transcription content')
      end
    end

    context 'with invalid parameters' do
      it 'returns errors' do
        allow_any_instance_of(Transcription).to receive(:save).and_return(false)
        allow_any_instance_of(Transcription).to receive_message_chain(:errors, :full_messages).and_return(['Error message'])

        post :create, params: { transcription: { content: '' } }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET #summary' do
    let(:transcription) { Transcription.create!(content: 'Test content', status: 'completed', summary: 'Test summary') }

    context 'when summary exists' do
      it 'returns the existing summary' do
        get :summary, params: { id: transcription.id }, format: :json
        json_response = JSON.parse(response.body)

        expect(json_response['summary']).to eq('Test summary')
        expect(json_response['status']).to eq('completed')
      end
    end

    context 'when summary does not exist' do
      before do
        transcription.update(summary: nil)
        allow_any_instance_of(Transcription).to receive(:generate_summary) do |instance|
          instance.update(summary: 'Generated summary', status: 'completed')
        end
      end

      it 'generates a new summary' do
        get :summary, params: { id: transcription.id }, format: :json
        json_response = JSON.parse(response.body)

        expect(json_response['summary']).to be_present
      end
    end
  end

  describe 'GET #show' do
    let(:transcription) { Transcription.create!(content: 'Test content', status: 'completed') }

    it 'returns a successful response' do
      get :show, params: { id: transcription.id }
      expect(response).to be_successful
    end

    it 'assigns the requested transcription' do
      get :show, params: { id: transcription.id }
      expect(assigns(:transcription)).to eq(transcription)
    end

    context 'when requesting JSON' do
      it 'returns JSON representation' do
        get :show, params: { id: transcription.id }, format: :json
        expect(response.content_type).to include('application/json')
      end
    end
  end
end

