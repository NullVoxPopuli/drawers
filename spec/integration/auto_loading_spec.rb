# frozen_string_literal: true
require 'rails_helper'

describe 'Auto Loading' do
  it 'loads the post resources' do
    # trigger autoload
    Post
    PostSerializer
    PostsController
    expect(defined? Post).to be true
    expect(defined? PostsController).to be true
    expect(defined? PostSerializer).to be true
  end
end
