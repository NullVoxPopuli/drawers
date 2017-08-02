# frozen_string_literal: true
module Drawers
  class ResourceParts
    attr_reader :namespace, :resource_name,
      :resource_type, :named_resource_type,
      :class_path

    class << self
      def from_name(name)
        resource = call(name)

        [
          resource.namespace,
          resource.resource_name,
          resource.resource_type,
          resource.named_resource_type,
          resource.class_path
        ]
      end

      def call(name)
        resource = new(name)
        resource.call
        resource
      end
    end

    def initialize(name)
      @qualified_name = name
    end

    def call
      # if this is not part of a resource, don't even bother
      return unless index_of_resource_type

      # Api, V2, Post, Operations, Update
      # => Operations
      @resource_type = qualified_parts[index_of_resource_type]

      # Api, V2, Post, Operations, Update
      # => Posts
      #
      # Posts, Controller
      # => Posts
      original_resource_name = qualified_parts[index_of_resource_type - 1]
      @resource_name = original_resource_name.pluralize

      # Posts_Controller
      # Post_Operations
      @named_resource_type = "#{original_resource_name}_#{@resource_type}"

      # Api, V2, Post, Operations, Update
      # => Api, V2
      namespace_index = index_of_resource_type - 1
      @namespace = namespace_index < 1 ? '' : qualified_parts.take(namespace_index)

      # Api, V2, Post, Operations, Update
      # => Update
      class_index = index_of_resource_type + 1
      @class_path = class_index < 1 ? '' : qualified_parts.drop(class_index)
    end

    private

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
    def qualified_parts
      @qualified_parts ||= @qualified_name
                           .split(Drawers.qualified_name_split)
                           .reject(&:blank?)
    end

    # based on the position of of the resource type name,
    # anything to the left will be the namespace, and anything
    # to the right will be the file path within the namespace
    # (may be obvious, but basically, we're 'pivoting' on RESOURCE_SUFFIX_NAMES)
    #
    # Given: Api, V2, Post, Operations, Update
    #                           ^ index_of_resource_type (3)
    def index_of_resource_type
      @index_of_resource_type ||= qualified_parts.index { |x| Drawers.resource_suffixes.include?(x) }
    end
  end
end
