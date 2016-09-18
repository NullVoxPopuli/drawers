# frozen_string_literal: true
module RailsModuleUnification
  module ActiveSupportExtensions
    def load_from_path(file_path, qualified_name, from_mod, const_name)
      expanded = File.expand_path(file_path)
      expanded.sub!(/\.rb\z/, '')

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
    end
  end
end
