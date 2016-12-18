# frozen_string_literal: true
namespace :rmu do
  config_path = "#{Rails.root}/config/initializers/drawers"
  config_exists = File.exist?(config_path)
  require config_path if config_exists

  # @example
  #  rake rmu:migrate_resource Post
  # @example
  #  rake rmu:migrate_resource Api::Event

  desc 'Moves all files related to a resource to the RMU directory'
  task :migrate_resource, [:klass_name] => :environment do |_t, args|
    klass_name = args[:klass_name]

    # Given klass_name,
    # check known places where related files could be
    singular = possible_classes(klass_name)
    plural = possible_classes(klass_name, plural: true)

    possibilities = singular + plural

    possibilities.each do |possible_class|
      klass = possible_class.safe_constantize

      next unless klass

      location = location_of(klass)

      unless location
        puts "#{klass.name} could not be found"
        next
      end

      next if already_moved?(location)

      destination = destination_for(location)
      move_file(location, to: destination)
    end
  end

  def destination_for(path)
    # Rails.root does not include 'app/'
    project_root = Rails.root.to_s
    relative_path = path.sub(project_root, '')
    relative_path_parts = relative_path.split('/').reject(&:blank?)

    # remove app dir
    # ["app", "serializers", "hosted_event_serializer.rb"]
    # => ["serializers", "hosted_event_serializer.rb"]
    relative_path_parts.shift

    return if relative_path_parts.length < 2

    # resource type (controller, serializer, etc)
    # ["serializers", "hosted_event_serializer.rb"]
    # => serializer
    resource_type = relative_path_parts.shift.singularize

    # ["hosted_event_serializer.rb"]
    # => hosted_event_serializer.rb
    file_name = relative_path_parts.pop

    resource_name, extension = file_name.split("_#{resource_type}")

    namespace = relative_path_parts.join('/')

    destination = [
      project_root,
      'app',
      Drawers.directory,
      'resources',
      namespace,
      resource_name.pluralize,
      resource_type
    ].reject(&:blank?).join('/')

    destination + extension
  end

  def move_file(from, to: nil)
    puts "Moving #{from} to #{to}"
    return unless to && from

    matches = /.+\/(.+\.\w+)/.match(to)
    file = matches[1]
    path = to.sub(file, '')

    unless File.directory?(path)
      puts 'creating directory...'
      FileUtils.mkdir_p(path)
    end

    FileUtils.move(from, to)
  end

  # See RESOURCE_SUFFIX_NAMES for total options
  # PostSerializer
  SINGULAR_RESOURCE_SUFFIXES = %w(
    Serializer
    Operations
    Presenters
    Policy
    Policies
  ).freeze

  # PostsController
  PLURAL_RESOURCE_SUFFIXES = %w(
    Controller
  ).freeze

  def possible_classes(resource_name, plural: false)
    klass_name = plural ? resource_name.pluralize : resource_name
    suffixes = plural ? PLURAL_RESOURCE_SUFFIXES : SINGULAR_RESOURCE_SUFFIXES
    suffixes.map { |suffix| "#{klass_name}#{suffix}" }
  end

  def location_of(klass)
    # Flat default rails structure
    guessed_path = guess_file_path(klass)
    return guessed_path if File.exist?(guessed_path)

    # Try to find the file based on method source location
    # - will not work if a file doesn't define any methods
    #   ( empty sub classes )
    root = Rails.root.to_s
    possible_paths = klass.instance_methods(false).map do |m|
      klass.instance_method(m).source_location.first
    end.uniq

    possible_paths.select { |path| path.include?(root) }.first
  end

  def already_moved?(location)
    location.include?("#{Drawers.directory}/resources")
  end

  def guess_file_path(klass)
    underscored = klass.name.underscore
    file_name = underscored + '.rb'
    resource_type = underscored.split('_').last

    guessed_path = File.join(
      Rails.root,
      'app',
      resource_type.pluralize,
      file_name
    )

    guessed_path
  end
end
