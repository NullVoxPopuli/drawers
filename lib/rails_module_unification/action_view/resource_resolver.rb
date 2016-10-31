# frozen_string_literal: true

require 'action_view'

module RailsModuleUnification
  class ResourceResolver < ::ActionView::OptimizedFileSystemResolver
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
