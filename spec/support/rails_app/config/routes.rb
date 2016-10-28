# frozen_string_literal: true
Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    resources :posts
    resources :authors

    namespace :v2 do
      resources :categories
    end
  end

  resources :comments do
    resources :replies, controller: 'comments/replies'
  end
end
