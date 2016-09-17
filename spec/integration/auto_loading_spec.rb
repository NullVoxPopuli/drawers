# frozen_string_literal: true
require 'rails_helper'

describe 'Auto Loading' do
  context 'with traditionally named files' do
    it 'loads the model' do
      expect(Post).to be_truthy
    end

    it 'loads the serializer' do
      expect(Api::PostSerializer).to be_truthy
    end

    it 'loads the controller' do
      expect(Api::PostsController).to be_truthy
    end
  end

  context 'with files named after type (and folder named after the resource)' do
    it 'loads the model' do
      expect(Author).to be_truthy
    end

    it 'loads the serializer' do
      expect(Api::AuthorSerializer).to be_truthy
    end

    it 'loads the controller' do
      expect(Api::AuthorsController).to be_truthy
    end
  end

  context 'with files that are not namespaced' do
    it 'loads the serializer' do
      expect(CommentSerializer).to be_truthy
    end

    it 'loads the controller' do
      expect(CommentsController).to be_truthy
    end
  end

  context 'with files that are deeply namespaced' do

  end
end
