# frozen_string_literal: true
module RailsModuleUnification
  module ActiveSupportExtensions
    RESOURCE_SUFFIX_NAMES = %w(
      Controller
      Serializer
      Operations
      Presenters
      Policy
      Policies
    ).freeze

    # Join all the suffix names together with an "OR" operator
    RESOURCE_SUFFIXES = /(#{RESOURCE_SUFFIX_NAMES.join('|')})/

    # split on any of the resource suffixes OR the ruby namespace seperator
    QUALIFIED_NAME_SPLIT = /::|#{RESOURCE_SUFFIXES}/

    def load_from_path(file_path, qualified_name, from_mod, const_name)
      expanded = File.expand_path(file_path)
      expanded.sub!(/\.rb\z/, '')

      if loading.include?(expanded)
        raise "Circular dependency detected while autoloading constant #{qualified_name}"
      else
        require_or_load(expanded, qualified_name)
        unless from_mod.const_defined?(const_name, false)
          raise LoadError, "Unable to autoload constant #{qualified_name}, expected #{file_path} to define it"
        end

        return from_mod.const_get(const_name)
      end
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
      # 1. break apart the qualified name into pieces that can easily be
      #    manipulated
      #
      # Api::Posts
      # => Api, Posts
      #
      # Api::PostOperations::Create
      # => Api, Post, Operations, Create
      #
      # Api::PostsController
      # => Api, Posts, Controller
      #
      # Api::V2::PostOperations::Update
      # => Api, V2, Post, Operations, Update
      qualified_parts = qualified_name.split(QUALIFIED_NAME_SPLIT).reject(&:blank?)

      # based on the position of of the resource type name,
      # anything to the left will be the namespace, and anything
      # to the right will be the file path within the namespace
      # (may be obvious, but basically, we're 'pivoting' on RESOURCE_SUFFIX_NAMES)
      #
      # Given: Api, V2, Post, Operations, Update
      #                           ^ index_of_resource_type (3)
      index_of_resource_type = qualified_parts.index { |x| RESOURCE_SUFFIX_NAMES.include?(x) }

      # if this is not part of a resource, don't even bother
      return unless index_of_resource_type

      # Api, V2, Post, Operations, Update
      # => Operations
      # leaving Api, V2, Post, Update
      resource_type = qualified_parts[index_of_resource_type]

      # Api, V2, Post, Operations, Update
      # => Posts
      #
      # Posts, Controller
      # => Posts
      original_resource_name = qualified_parts[index_of_resource_type - 1]
      resource_name = original_resource_name.pluralize

      # TODO: can this be an array?
      # Posts_Controller
      # Post_Operations
      named_resource_type = "#{original_resource_name}_#{resource_type}"

      # Api, V2, Update
      # => Api, V2
      namespace_index = index_of_resource_type - 1
      namespace = namespace_index < 1 ? '' : qualified_parts.take(namespace_index)

      # Api, V2, Update
      # => Update
      class_index = index_of_resource_type + 1
      class_path = class_index < 1 ? '' : qualified_parts.drop(class_index)
      path_options = [

        # api/v2/posts/operations/update
        to_path(namespace, resource_name, resource_type, class_path),

        # api/v2/posts/post_operations/update
        to_path(namespace, resource_name, named_resource_type, class_path),

        # api/v2/posts/posts_controller
        to_path(namespace, resource_name, named_resource_type),

        # api/v2/posts/controller
        to_path(namespace, resource_name, resource_type)
      ].uniq

      file_path = ''
      path_options.each do |path_option|
        file_path = search_for_file(path_option)

        break if file_path.present?
      end

      file_path
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
    rescue LoadError, NameError
      load_missing_constant_error(from_mod, const_name)
    end

    # the heavy liftign of Rails Module Unification is just
    # adding some additional pathfinding / constat lookup logic
    # when the default (super) can't find what needs to be found
    def load_missing_constant_error(from_mod, const_name)
      # examples
      # - Api::PostsController
      # - PostsController
      qualified_name = qualified_name_for(from_mod, const_name)
      file_path = resource_path_from_qualified_name(qualified_name)

      begin
        return load_from_path(file_path, qualified_name, from_mod, const_name) if file_path
      rescue LoadError, NameError
        # Recurse!
        # not found, check the parent
        load_missing_constant(from_mod.parent, const_name)
      end

      name_error = NameError.new("uninitialized constant #{qualified_name}", const_name)
      name_error.set_backtrace(caller.reject { |l| l.starts_with? __FILE__ })
      raise name_error
    end
  end
end
