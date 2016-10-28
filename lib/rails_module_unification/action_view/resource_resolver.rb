# frozen_string_literal: true
module RailsModuleUnification
  class ResourceResolver < ::ActionView::OptimizedFileSystemResolver
    require 'pry-byebug'
    def initialize
      path = [
        Rails.root,
        'app',
        RailsModuleUnification.directory,
        'resources'
      ].reject(&:blank?).join('/')

      super(path)
      @path = path
    end

    # def find_templates(name, prefix, partial, details)
    #   binding.pry
    #   super(name, prefix, partial, details)
    # end
    #
    # def build_query(path, details)
    #
    #   query = @pattern.dup
    #
    #   binding.pry
    #   prefix = path.prefix.empty? ? '' : "#{escape_entry(path.prefix)}\\1"
    #   query.gsub!(/:prefix(\/)?/, prefix)
    #
    #   partial = escape_entry(path.partial? ? "_#{path.name}" : path.name)
    #   query.gsub!(/:action/, partial)
    #
    #   details.each do |ext, candidates|
    #     if ext == :variants && candidates == :any
    #       query.gsub!(/:#{ext}/, "*")
    #     else
    #       query.gsub!(/:#{ext}/, "{#{candidates.compact.uniq.join(',')}}")
    #     end
    #   end
    #   puts File.expand_path(query, @path)
    #   File.expand_path(query, @path)
    # end
  end
end
