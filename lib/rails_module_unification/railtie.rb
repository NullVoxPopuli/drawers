# frozen_string_literal: true
require 'rails/railtie'

module RailsModuleUnification
  class Railtie < Rails::Railtie
    railtie_name :rails_module_unification

    rake_tasks do
      load 'tasks/rails_module_unification.rake'
    end

    # for customizing where the new folder structure is
    # by default, everything still resides in Rails.root/app
    config_path = "#{Rails.root}/config/initializers/rails_module_unification"
    config_exists = File.exist?(config_path)
    require config_path if config_exists
    mu_dir = "#{Rails.root}/app/#{RailsModuleUnification.directory}"

    # add folders to autoload paths
    initializer 'activeservice.autoload', before: :set_autoload_paths do |app|
      # Data
      data_paths = Dir["#{mu_dir}/models/data/**/"]
      app.config.autoload_paths += data_paths

      # Resources
      resource_paths = Dir["#{mu_dir}/resources/"]
      app.config.autoload_paths += resource_paths
    end
  end
end
