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

    def load_from_parent(from_mod, const_name)
      # If our parents do not have a constant named +const_name+ then we are free
      # to attempt to load upwards. If they do have such a constant, then this
      # const_missing must be due to from_mod::const_name, which should not
      # return constants from from_mod's parents.
      parent = from_mod.parent
      present_in_ancestry = (
        parent &&
        parent != from_mod &&
        !from_mod.parents.any? { |p| p.const_defined?(const_name, false) }
      )

      # Since Ruby does not pass the nesting at the point the unknown
      # constant triggered the callback we cannot fully emulate constant
      # name lookup and need to make a trade-off: we are going to assume
      # that the nesting in the body of Foo::Bar is [Foo::Bar, Foo] even
      # though it might not be. Counterexamples are
      #
      #   class Foo::Bar
      #     Module.nesting # => [Foo::Bar]
      #   end
      #
      # or
      #
      #   module M::N
      #     module S::T
      #       Module.nesting # => [S::T, M::N]
      #     end
      #   end
      #
      # for example.
      return parent.const_missing(const_name) if present_in_ancestry
    rescue NameError => e
      raise unless e.missing_name? qualified_name_for(parent, const_name)
    end

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

      # examples:
      # - posts/posts_controller
      folder_named_type = folder_name + '/' + file_name

      # folder/type.rb
      # e.g.: posts/controller.rb
      folder_type_name = folder_name + '/' + type_name

      # folder/sub_folder_type/type.rb
      # e.g.: posts/operations/create.rb
      sub_folder_type_name = "#{folder_name}/#{sub_folder_type}/#{type_name}"

      # folder/named_sub_folder_type/type
      sub_folder_named_type = "#{folder_name}/#{resource_folder_name.singularize}_#{sub_folder_type}/#{type_name}"

      # without a folder / namespace?
      # TODO: could this have undesired consequences?
      file_path = search_for_file(file_name)

      # class is defined IN the parent
      # e.g.: LevelOperations::Read in level_operations.rb
      file_path ||= search_for_file(parent_name)

      # the resource_name/controller.rb naming scheme
      file_path ||= search_for_file(folder_type_name)

      # the resource_name/resource_names_controller.rb naming scheme
      file_path ||= search_for_file(folder_named_type)

      # the resource_name/operations/action.rb naming scheme
      file_path ||= search_for_file(sub_folder_type_name)

      # the resource_name/resource_name_operations/action.rb naming scheme
      file_path ||= search_for_file(sub_folder_named_type)

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
      qualified_name = qualified_name_for from_mod, const_name
      file_path = resource_path_from_qualified_name(qualified_name)

      begin
        return load_from_path(file_path, qualified_name, from_mod, const_name) if file_path
      rescue LoadError, NameError
        # Recurse!
        # not found, check the parent
        load_missing_constant(from_mod.parent, const_name)
      end

      # TODO: describe the situation in which this is needed
      if file_path
        matches = /^.+\/([^\/]+)$/.match(file_path)
        file_name = matches[1]
        mod = autoload_module!(from_mod, const_name, qualified_name, file_name)
        return mod if mod
      end

      from_parent = load_from_parent(from_mod, const_name)
      return from_parent if from_parent

      name_error = NameError.new("uninitialized constant #{qualified_name}", const_name)
      name_error.set_backtrace(caller.reject { |l| l.starts_with? __FILE__ })
      raise name_error
    end
  end
end
