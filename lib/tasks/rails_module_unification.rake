namespace :rmu do

  # @example
  #  rake rmu:move_resource_files Post ensure_namespace=Api

  desc 'Moves all files related to a resource to the RMU directory'
  task :move_resource_files do
    _t, klass_name, ensure_namespace_arg = ARGV

    ensure_namespace = false

    # with ensure_namespace set to 'Api' (for example),
    # for anything already with teh api namespace, do nothing,
    # otherwise,
    # - add module Api at the top
    # - indent following lines by 2 spaces
    # - add 'end' at the bottom
    if ensure_namespace_arg.present?
      parts = ensure_namespace_arg.split('=')
      ensure_namespace = parts.last if parts.count == 2
    end

    # Given klass_name,
    # check known places where related files could be

  end
end
