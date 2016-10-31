# frozen_string_literal: true
require 'rails/railtie'
require 'action_controller'

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

    # add folders to autoload paths
    initializer 'activeservice.autoload', before: :set_autoload_paths do |app|
      mu_dir = [
        Rails.root,
        'app',
        RailsModuleUnification.directory
      ].reject(&:blank?).join('/')

      # New location for ActiveRecord Models
      app.config.autoload_paths << "#{mu_dir}/models/data"

      # Resources
      app.config.autoload_paths << "#{mu_dir}/resources/"
    end

    config.after_initialize do
      ActionController::Base.prepend_view_path RailsModuleUnification::ResourceResolver.new
    end
  end
end
