# frozen_string_literal: true
module Drawers
  module DependencyExtensions
    ERROR_CIRCULAR_DEPENDENCY = 'Circular dependency detected while autoloading constant'

    def load_from_path(file_path, qualified_name, from_mod, const_name)
      expanded = File.expand_path(file_path)
      expanded.sub!(/\.rb\z/, '')

      raise "#{ERROR_CIRCULAR_DEPENDENCY} #{qualified_name}" if loading.include?(expanded)

      require_or_load(expanded, qualified_name)
      unless from_mod.const_defined?(const_name, false)
        raise LoadError, "Unable to autoload constant #{qualified_name}, expected #{file_path} to define it"
      end

      from_mod.const_get(const_name)
    end

    # A look for the possible places that various qualified names could be
    #
    # @note The Lookup Rules:
    #   - all resources are plural
    #   - file_names can either be named after the type or traditional ruby/rails nameing
    #     i.e.: posts_controller.rb vs controller.rb
    #   - regular namespacing still applies.
    #     i.e: Api::V2::CategoriesController should be in
    #          api/v2/categories/controller.rb
    #
    # @note The Pattern:
    #  - namespace_a                        - api
    #    - namespace_b                        - v2
    #      - resource_name (plural)             - posts
    #        - file_type.rb                       - controller.rb (or posts_controller.rb)
    #                                             - operations.rb (or post_operations.rb)
    #        - folder_type                        - operations/   (or post_operations/)
    #          - related namespaced classes         - create.rb
    #
    # All examples assume default resource directory ("resources")
    # and show the order of lookup
    #
    # @example Api::PostsController
    #   Possible Locations
    #    - api/posts/controller.rb
    #    - api/posts/posts_controller.rb
    #
    # @example Api::PostSerializer
    #   Possible Locations
    #    - api/posts/serializer.rb
    #    - api/posts/post_serializer.rb
    #
    # @example Api::PostOperations::Create
    #   Possible Locations
    #    - api/posts/operations/create.rb
    #    - api/posts/post_operations/create.rb
    #
    # @example Api::V2::CategoriesController
    #   Possible Locations
    #    - api/v2/categories/controller.rb
    #    - api/v2/categories/categories_controller.rb
    #
    # @param [String] qualified_name fully qualified class/module name to find the file location for
    def resource_path_from_qualified_name(qualified_name)
      path_options = path_options_for_qualified_name(qualified_name)

      file_path = ''
      path_options.uniq.each do |path_option|
        file_path = search_for_file(path_option)

        break if file_path.present?
      end

      return file_path if file_path

      # Note that sometimes, the resource_type path may only be defined in a
      # resource type folder
      # So, look for the first file within the resource type folder
      # because of ruby namespacing conventions if there is a file in the folder,
      # it MUST define the namespace
      path_for_first_file_in(path_options.last) || path_for_first_file_in(path_options[-2])
    end

    def path_options_for_qualified_name(qualified_name)
      namespace,
      resource_name,
      resource_type, named_resource_type,
      class_path = ResourceParts.from_name(qualified_name)

      # build all the possible places that this file could be
      [
        # api/v2/posts/operations/update
        to_path(namespace, resource_name, resource_type, class_path),

        # api/v2/posts/post_operations/update
        to_path(namespace, resource_name, named_resource_type, class_path),

        # api/v2/posts/posts_controller
        to_path(namespace, resource_name, named_resource_type),

        # api/v2/posts/controller
        to_path(namespace, resource_name, resource_type)
      ]
    end

    def path_for_first_file_in(path)
      return if path.blank?

      path_in_app = "#{Rails.root}/app/resources/#{path.pluralize}"
      return unless File.directory?(path_in_app)

      Dir.glob("#{path_in_app}/*.rb").first
    end

    def to_path(*args)
      args.flatten.reject(&:blank?).map(&:underscore).join('/')
    end

    # Load the constant named +const_name+ which is missing from +from_mod+. If
    # it is not possible to load the constant into from_mod, try its parent
    # module using +const_missing+.
    def load_missing_constant(from_mod, const_name)
      # always default to the actual implementation
      super
    rescue LoadError, NameError => e
      load_missing_constant_error(from_mod, const_name, e)
    end

    # the heavy lifting of Drawers is just
    # adding some additional pathfinding / constat lookup logic
    # when the default (super) can't find what needs to be found
    #
    # @param [Class] from_mod - parent module / class that const_name may be a part of
    # @param [Symbol] const_name - potential constant to lookup under from_mod
    # @param [Exception] e - exception from previous error
    def load_missing_constant_error(from_mod, const_name, e)
      # examples
      # - Api::PostsController
      # - PostsController
      qualified_name = qualified_name_for(from_mod, const_name)
      file_path = resource_path_from_qualified_name(qualified_name)

      begin
        return load_from_path(file_path, qualified_name, from_mod, const_name) if file_path
      rescue LoadError, NameError => e
        # Recurse!
        # not found, check the parent
        at_the_top = from_mod.parent == from_mod
        return load_missing_constant_error(from_mod.parent, const_name, e) unless at_the_top
        raise e
      end

      name_error = NameError.new(e.message)
      name_error.set_backtrace(caller.reject { |l| l.starts_with? __FILE__ })
      raise name_error
    end
  end
end
