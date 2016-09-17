module RailsModuleUnification
  module ActiveSupportExtensions
    def load_from_path(file_path, qualified_name, from_mod, const_name)
      expanded = File.expand_path(file_path)
      expanded.sub!(/\.rb\z/, ''.freeze)

      if loading.include?(expanded)
        raise "Circular dependency detected while autoloading constant #{qualified_name}"
      else
        require_or_load(expanded, qualified_name)
        raise LoadError, "Unable to autoload constant #{qualified_name}, expected #{file_path} to define it" unless from_mod.const_defined?(const_name, false)
        return from_mod.const_get(const_name)
      end
    end

    # Load the constant named +const_name+ which is missing from +from_mod+. If
    # it is not possible to load the constant into from_mod, try its parent
    # module using +const_missing+.
    def load_missing_constant(from_mod, const_name)
      # always default to the actual implementation
      super
    rescue LoadError, NameError
      suffixes = /(Controller|Serializer)\z/

      # examples
      # - Api::PostsController
      # - PostsController
      qualified_name = qualified_name_for from_mod, const_name

      # examples
      # - api/posts_controller
      # - posts_controller
      file_name = qualified_name.underscore.split('/').last

      # examples
      # - controller
      # - serializer
      type_name = file_name.split('_').last

      # folder/named_type.rb
      # examples:
      # - api/posts
      # - posts
      folder_name = qualified_name.split(suffixes).first.underscore.pluralize

      # examples:
      # - posts/posts_controller
      folder_named_type = folder_name + '/' + file_name

      # folder/type.rb
      folder_type_name = folder_name + '/' + type_name


      # without a folder / namespace?
      # TODO: could this have undesired consequences?
      file_path = search_for_file(file_name)
      # the resource_name/controller.rb naming scheme
      file_path ||= search_for_file(folder_type_name)
      # the resource_name/resource_names_controller.rb naming scheme
      file_path ||= search_for_file(folder_named_type)

      return load_from_path(file_path, qualified_name, from_mod, const_name) if file_path


      if mod = autoload_module!(from_mod, const_name, qualified_name, file_name)
        return mod
      elsif (parent = from_mod.parent) && parent != from_mod &&
            ! from_mod.parents.any? { |p| p.const_defined?(const_name, false) }
        # If our parents do not have a constant named +const_name+ then we are free
        # to attempt to load upwards. If they do have such a constant, then this
        # const_missing must be due to from_mod::const_name, which should not
        # return constants from from_mod's parents.
        begin
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
          return parent.const_missing(const_name)
        rescue NameError => e
          raise unless e.missing_name? qualified_name_for(parent, const_name)
        end
      end

      name_error = NameError.new("uninitialized constant #{qualified_name}", const_name)
      name_error.set_backtrace(caller.reject {|l| l.starts_with? __FILE__ })
      raise name_error
    end
  end
end
