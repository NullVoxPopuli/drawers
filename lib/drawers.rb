# frozen_string_literal: true

require 'active_support'

module Drawers
  require 'drawers/active_support/dependency_extensions'
  require 'drawers/action_view/path_extensions'
  require 'drawers/action_view/resource_resolver'
  require 'drawers/resource_parts'

  module_function

  def directory=(dir)
    @directory = dir
  end

  def directory
    @directory || ''
  end

  require 'drawers/railtie'
  ActiveSupport::Dependencies.extend Drawers::DependencyExtensions
  ActionController::Base.extend Drawers::PathExtensions

  if Rails.version > '5'
    ActionController::API.extend Drawers::PathExtensions
  end
end
