# frozen_string_literal: true
module Drawers
  # prepend view paths, setting preferential lookup to the new
  # RMU folders
  #
  # lookup pattern
  #   resources/:namespace/:resource/views/:action/{.:locale,}{.:formats,}{+:variants,}{.:handlers,}
  #   prefix = resources/:namespace/:resource/views/
  #
  # default lookup pattern (for reference (as of 5.0.0.1))
  #   :prefix/:action{.:locale,}{.:formats,}{+:variants,}{.:handlers,}
  #
  # This module should only be used as class methods on the inheriting object
  module PathExtensions
    def local_prefixes
      [_rmu_resource_path] + super
    end

    private

    def _rmu_resource_path
      [
        _namespace,
        _resource_name,
        'views'
      ].flatten.reject(&:blank?).map(&:underscore).join('/')
    end

    def _resource_name
      controller_name
    end

    def _namespace
      _resource_parts.namespace
    end

    def _resource_parts
      @_resource_parts ||= Drawers::ResourceParts.call(name)
    end
  end
end
