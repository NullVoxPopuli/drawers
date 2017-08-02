# frozen_string_literal: true

require 'active_support'

module Drawers
  DEFAULT_RESOURCE_SUFFIXES = %w(
    Controller
    Forms
    Serializer
    Operations
    Presenters
    Policy
    Policies
    Services
  ).freeze

  require 'drawers/active_support/dependency_extensions'
  require 'drawers/action_view/path_extensions'
  require 'drawers/action_view/resource_resolver'
  require 'drawers/resource_parts'

  module_function

  def resource_suffixes
    @resource_suffixes || DEFAULT_RESOURCE_SUFFIXES
  end

  def resource_suffixes=(suffixes)
    @resource_suffixes = suffixes.freeze
  end

  def directory=(dir)
    @directory = dir
  end

  def directory
    @directory || ''
  end

  # @api private
  # Join all the suffix names together with an "OR" operator
  def resource_suffixes_regex
    /(#{resource_suffixes.join('|')})/
  end

  # @api private
  # split on any of the resource suffixes OR the ruby namespace seperator
  def qualified_name_split
    /::|#{resource_suffixes_regex}/
  end

  require 'drawers/railtie'

  ActiveSupport::Dependencies.extend Drawers::DependencyExtensions
  ActionController::Base.extend Drawers::PathExtensions
  ActionController::API.extend Drawers::PathExtensions if Rails.version > '5'
end
