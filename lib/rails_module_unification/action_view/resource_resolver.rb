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
  end
end
