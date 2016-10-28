# frozen_string_literal: true
require 'rails_helper'

describe 'View Lookup' do
  context 'without a namespace' do
    describe CommentsController, type: :request do
      describe '/index' do
        it 'renders the html' do
          get '/comments'
          body = response.body

          File.open('error.html', 'w') { |file| file.write(body) }
          expect(response.status).to eq 200
          expect(body).to include('Index HTML')
          expect(body).to include('Some Partial')
        end

        xit 'renders jbuilder' do
          # blocked by:
          # https://github.com/rails/jbuilder/issues/346
          # should work after that is fixed
          headers = {
            'ACCEPT' => 'application/json',
            'CONTENT_TYPE' => 'application/json'
          }
          get '/comments.json', {}, headers
          body = response.body
          expect(response.status).to eq 200
          expect(body).to include('jbuilder')
        end
      end
    end
  end

  context 'with a namespace' do
    describe Comments::RepliesController, type: :request do
      describe '/index' do
        it 'renders the html' do
          get '/comments/1/replies'
          body = response.body
          expect(response.status).to eq 200
          expect(body).to include('Some replies to comments')
        end
      end
    end
  end
end
