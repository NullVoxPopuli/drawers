module RailsModuleUnification
  module ActiveSupportExtensions
    # Load the constant named +const_name+ which is missing from +from_mod+. If
    # it is not possible to load the constant into from_mod, try its parent
    # module using +const_missing+.
    def load_missing_constant(from_mod, const_name)
      # always default to the actual implementation
      super
    rescue LoadError

      # TODO: Remove all this, because super does it.
      unless qualified_const_defined?(from_mod.name) && ActiveSupport::Inflector.constantize(from_mod.name).equal?(from_mod)
        raise ArgumentError, "A copy of #{from_mod} has been removed from the module tree but is still active!"
      end

      qualified_name = qualified_name_for from_mod, const_name
      path_suffix = qualified_name.underscore

      file_path = search_for_file(path_suffix)

      if file_path
        expanded = File.expand_path(file_path)
        expanded.sub!(/\.rb\z/, ''.freeze)

        if loading.include?(expanded)
          raise "Circular dependency detected while autoloading constant #{qualified_name}"
        else
          require_or_load(expanded, qualified_name)
          raise LoadError, "Unable to autoload constant #{qualified_name}, expected #{file_path} to define it" unless from_mod.const_defined?(const_name, false)
          return from_mod.const_get(const_name)
        end
      elsif mod = autoload_module!(from_mod, const_name, qualified_name, path_suffix)
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
