# frozen_string_literal: true

require 'active_support'
require 'rails_module_unification/active_support_extensions'

module RailsModuleUnification
  extend ActiveSupport::Autoload

  module_function

  def directory=(dir)
    @directory = dir
  end

  def directory
    @directory || ''
  end

  require 'rails_module_unification/railtie'
  ActiveSupport::Dependencies.extend RailsModuleUnification::ActiveSupportExtensions
end
