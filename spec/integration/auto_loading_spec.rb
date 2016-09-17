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
      Author
      expect(defined? Post).to be_truthy
    end

    it 'loads the serializer' do
      Api::AuthorSerializer
      expect(defined? Api::AuthorSerializer).to be_truthy
    end

    it 'loads the controller' do
      Api::AuthorsController
      expect(defined? Api::AuthorsController).to be_truthy
    end
  end

  context 'with files that are not namespaced' do

  end

  context 'with files that are deeply namespaced' do

  end
end
