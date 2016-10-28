class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  rescue_from StandardError do |exception|
    puts exception.backtrace
    raise exception
  end
end
