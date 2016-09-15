# frozen_string_literal: true

require 'active_support'
require 'rails_module_unification/active_support_extensions'

module RailsModuleUnification
  extend ActiveSupport::Autoload

  require 'rails_module_unification/railtie'
  ActiveSupport::Dependencies.extend ActiveSupportExtensions
end
