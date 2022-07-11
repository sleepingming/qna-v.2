require 'rails_helper'

describe 'Questions API', type: :request do
  let(:headers) do
    { 'CONTENT_TYPE' => 'application/json',
      'ACCEPT' => 'application/json' }
  end

  describe 'GET /api/v1/questions' do
    let(:api_path) { '/api/v1/questions' }
    it_behaves_like 'API Authorizable' do
      let(:method) { :get }
    end

    context 'authorized' do
      let(:access_token) { create(:access_token) }
      let!(:questions) { create_list(:question, 2) }
      let(:question) { questions.first }
      let(:question_response) { json['questions'].first }
      let!(:answers) { create_list(:answer, 3, question: question) }

      before { get api_path, params: { access_token: access_token.token }, headers: headers }

      it 'returns 200 status' do
        expect(response).to be_successful
      end

      it 'returns list of questions' do
        expect(json['questions'].size).to eq 2
      end

      it 'returns all public fields' do
        %w[id title body user_id created_at updated_at].each do |attr|
          expect(question_response[attr]).to eq questions.first.send(attr).as_json
        end
      end

      it 'contains user object' do
        expect(question_response['user']['id']).to eq question.user.id
      end

      describe 'answers' do
        let(:answer) { answers.first }
        let(:answer_response) { question_response['answers'].first }

        it 'returns list of answers' do
          expect(question_response['answers'].size).to eq 3
        end

        it 'returns all public fields' do
          %w[id body user_id created_at updated_at].each do |attr|
            expect(answer_response[attr]).to eq answer.send(attr).as_json
          end
        end
      end
    end
  end

  describe 'GET /api/v1/questions/:id' do
    let!(:question) { create(:question) }
    let(:api_path) { "/api/v1/questions/#{question.id}" }

    it_behaves_like 'API Authorizable' do
      let(:method) { :get }
    end

    context 'authorized' do
      let(:access_token) { create(:access_token) }
      let!(:question) { create(:question) }
      let(:question_response) { json['question'] }
      let(:links) { create_list(:link, 2, linkable: question) }
      let(:user) { create(:user) }
      let!(:comments) { create_list(:comment, 2, commentable: question, user: user) }

      before do
        question.files.attach(io: File.open("#{Rails.root}/spec/rails_helper.rb"), filename: 'rails_helper.rb')
        question.files.attach(io: File.open("#{Rails.root}/spec/rails_helper.rb"), filename: 'spec_helper.rb')

        get api_path, params: { access_token: access_token.token }, headers: headers
      end

      it 'returns 200 status' do
        expect(response).to be_successful
      end

      it_behaves_like 'API Fileable' do
        let(:fileable_response) { question_response['files'] }
      end

      it_behaves_like 'API Commentable' do
        let(:commentable_response) { question_response['comments'] }
      end
    end
  end

  describe 'DELETE /api/v1/questions/:id' do
    let(:headers) { { 'ACCEPT' => 'application/json' } }

    let(:access_token) { create(:access_token) }
    let(:question) { create(:question, user_id: access_token.resource_owner_id) }
    let(:method) { :delete }
    let(:api_path) { "/api/v1/questions/#{question.id}" }

    it_behaves_like 'API Authorizable'

    context 'authorized' do
      context 'author' do
        it 'deletes the question' do
          expect do
            do_request(method, api_path, params: { access_token: access_token.token },
                                         headers: headers)
          end.to change(question.user.questions, :count).by(-1)
        end

        it 'returns status 200' do
          do_request(method, api_path, params: { access_token: access_token.token }, headers: headers)
          expect(response).to be_successful
        end
      end

      context 'not author' do
        let(:question) { create(:question) }
        it "doesn't deletes the question" do
          expect do
            do_request(method, api_path, params: { access_token: access_token.token },
                                         headers: headers)
          end.to_not change(question.user.questions, :count)
        end
      end
    end
  end
end
