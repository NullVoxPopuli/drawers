# frozen_string_literal: true

require 'active_support'

module RailsModuleUnification
  extend ActiveSupport::Autoload

  autoload :Refinement
  require 'rails_module_unification/railtie'
end
