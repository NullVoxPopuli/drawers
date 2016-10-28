# frozen_string_literal: true

require 'active_support'

module RailsModuleUnification
  require 'rails_module_unification/active_support/dependency_extensions'
  require 'rails_module_unification/action_view/path_extensions'
  require 'rails_module_unification/resource_parts'

  module_function

  def directory=(dir)
    @directory = dir
  end

  def directory
    @directory || ''
  end

  require 'rails_module_unification/railtie'
  ActiveSupport::Dependencies.extend RailsModuleUnification::DependencyExtensions
  ActionController::Base.extend RailsModuleUnification::PathExtensions
  ActionController::API.extend RailsModuleUnification::PathExtensions
end
