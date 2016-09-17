# frozen_string_literal: true
require 'rails_helper'

describe 'Auto Loading' do
  context 'with traditionally named files' do
    it 'loads the model' do
      Post
      expect(defined? Post).to be_truthy
    end

    it 'loads the serializer' do
      Api::PostSerializer
      expect(defined? Api::PostSerializer).to be_truthy
    end

    it 'loads the controller' do
      Api::PostsController
      expect(defined? Api::PostsController).to be_truthy
    end
  end
end
