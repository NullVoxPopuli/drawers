# frozen_string_literal: true
require 'rails/railtie'

module RailsModuleUnification
  class Railtie < Rails::Railtie
    railtie_name :rails_module_unification

    rake_tasks do
      load 'tasks/rails_module_unification.rake'
    end

    initializer 'activeservice.autoload', before: :set_autoload_paths do |app|
      require "#{Rails.root}/config/initializers/rails_module_unification"

      # TODO: make the module unification root directory configurable
      mu_dir = "#{Rails.root}/app/#{RailsModuleUnification.directory}"

      # Data
      data_paths = Dir["#{mu_dir}/data/**/"]
      app.config.autoload_paths += data_paths

      # Resources
      resource_paths = Dir["#{mu_dir}/resources/"]
      app.config.autoload_paths += resource_paths
    end
  end
end
