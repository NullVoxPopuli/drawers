# frozen_string_literal: true
module RailsModuleUnification
  module ActiveSupportExtensions
    RESOURCE_SUFFIXES = /(Controller|Serializer|Operations?|Policy)/

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
    # All examples assume default resource directory ("resources")
    # and show the order of lookup
    # @example Api::PostsController
    #   Possible Locations
    #    - api/posts/controller.rb
    #    - api/posts/posts_controller.rb
    # @example Api::PostSerializer
    #   Possible Locations
    #    - api/posts/serializer.rb
    #    - api/posts/post_serializer.rb
    # @example Api::PostOperations::Create
    #   Possible Locations
    #    - api/posts/operations/create.rb
    #    - api/posts/post_operations/create.rb
    # @example Api::V2::CategoriesController
    #   Possible Locations
    #    - api/v2/categories/controller.rb
    #    - api/v2/categories/categories_controller.rb
    def resource_path_from_qualified_name(qualified_name)
      underscored_name = qualified_name.underscore
      qualified_name_parts = underscored_name.split('/')

      # examples
      # - api/posts_controller
      # - posts_controller
      file_name = qualified_name_parts.last

      # examples
      # - levels_operations/read in level_operations.rb
      #   ```ruby
      #   module LevelOperations
      #     class Read < SkinnyControllers::Operation::Base
      #   ```
      #
      # - api/post_operations/create.rb
      #
      #
      # Note that -2 is the index just before the last (the filename)
      # this will be empty if there is only one element is qualified_name_parts
      #
      parent_name = qualified_name_parts[0..-2].join('/')

      # examples
      # - level_operations/read in level_operations/read.rb
      #   namespace doesn't exist in a file of its own.
      #   Have to check directories and see if any of the files in
      #   those directories define the namespace

      # examples
      # - controller
      # - serializer
      type_name = file_name.split('_').last

      # folder/named_type.rb
      # examples:
      # - api/posts
      # - posts
      resource_parts = qualified_name.split(RESOURCE_SUFFIXES)
      folder_name = resource_parts.first.underscore.pluralize

      resource_name = resource_parts.first.demodulize
      resource_folder_name = resource_name.underscore.pluralize

      # sub type folder / name
      # examples:
      # - api/posts/operations/
      #   => operations
      # - api/posts/policies/
      #   => policies
      sub_folder_type = resource_parts[1].downcase if resource_parts[1] =~ RESOURCE_SUFFIXES


      # without a folder / namespace?
      # TODO: could this have undesired consequences?
      file_path = search_for_file(file_name)

      # class is defined IN the parent
      # e.g.: LevelOperations::Read in level_operations.rb
      file_path ||= search_for_file(parent_name)

      # folder/type.rb
      # e.g.: posts/controller.rb
      folder_type_name = "#{folder_name}/#{type_name}"
      # the resource_name/controller.rb naming scheme
      file_path ||= search_for_file(folder_type_name)

      # examples:
      # - posts/posts_controller
      folder_named_type = "#{folder_name}/#{file_name}"
      # the resource_name/resource_names_controller.rb naming scheme
      file_path ||= search_for_file(folder_named_type)

      if type_name == file_name
        # folder/sub_folder_type/type.rb
        # e.g.: posts/operations/create.rb
        sub_folder_type_name = "#{folder_name}/#{sub_folder_type}/#{type_name}"

        # the resource_name/operations/action.rb naming scheme
        file_path ||= search_for_file(sub_folder_type_name)

        # folder/named_sub_folder_type/type
        sub_folder_named_type = "#{folder_name}/#{resource_folder_name.singularize}_#{sub_folder_type}/#{type_name}"
        # the resource_name/resource_name_operations/action.rb naming scheme
        file_path ||= search_for_file(sub_folder_named_type)
      end

      if file_path.blank? && qualified_name.include?('AuthorOperations')
        puts '-------------------------------------'
        puts "qualified_name: \t #{qualified_name}"
        puts "file_name:   \t #{file_name}"
        puts "type_name:   \t #{type_name}"
        puts "parent_name: \t #{parent_name}"
        puts "folder_type_name: \t #{folder_type_name}"
        puts "folder_named_type: \t #{folder_named_type}"
        puts "sub_folder_type_name: \t #{sub_folder_type_name}"
        puts "sub_folder_named_type: \t #{sub_folder_named_type}"
        # binding.pry
      end

      file_path
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
