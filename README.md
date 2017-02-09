# Drawers
Group related classes together. No more silos.

[![Gem Version](https://badge.fury.io/rb/drawers.svg)](https://badge.fury.io/rb/drawers)
[![Build Status](https://travis-ci.org/NullVoxPopuli/drawers.svg?branch=master)](https://travis-ci.org/NullVoxPopuli/drawers)
[![Code Climate](https://codeclimate.com/github/NullVoxPopuli/drawers/badges/gpa.svg)](https://codeclimate.com/github/NullVoxPopuli/drawers)
[![Test Coverage](https://codeclimate.com/github/NullVoxPopuli/drawers/badges/coverage.svg)](https://codeclimate.com/github/NullVoxPopuli/drawers/coverage)
[![Dependency Status](https://gemnasium.com/badges/github.com/NullVoxPopuli/drawers.svg)](https://gemnasium.com/github.com/NullVoxPopuli/drawers)


## What is this about?

With large rails application, the default architecture can result in a resource's related files being very spread out through the overall project structure. For example, lets say you have 50 controllers, serializers, policies, and operations. That's _four_ different top level folders that spread out all the related objects. It makes sense do it this way, as it makes rails' autoloading programmatically easy.

This gem provides a way to re-structure your app so that like-objects are grouped together.

All this gem does is add some new autoloading / path resolution logic. This gem does not provide any service/operation/policy/etc functionality.

**All of this is optional, and can be slowly migrated to over time. Adding this gem does not force you to change your app.**

### The new structure

```ruby
app/
├── channels/
├── models/
│   ├── data/
│   │   ├── post.rb
│   │   └── comment.rb
│   └── graph_data.rb
├── jobs/
├── mailers/
│   └── notification_mailer.rb
└── resources/
    ├── posts/
    │   ├── forms/
    │   │   └── new_post_form.rb
    │   ├── controller.rb  # or posts_controller.rb
    │   ├── operations.rb  # or post_operations.rb
    │   ├── policy.rb      # or post_policy.rb
    │   └── serializer.rb  # or post_serializer.rb
    └── comments/
        ├── controller.rb
        ├── serializer.rb
        └── views/
            ├── index.html.erb
            └── create.html.erb

```

Does this new structure mean you have to change the class names of all your classes? Nope. In the above example file structure, `app/resources/posts/controller.rb` _still_ defines `class PostsController < ApplicationController`

[Checkout the sample rails app in the tests directory.](https://github.com/NullVoxPopuli/drawers/tree/master/spec/support/rails_app/app)

### The Convention

Say, for example, you have _any_ class/module defined as:

```ruby
module Api                    # {namespace
  module V3                   #  namespace}
    module UserServices       # {resource_name}{resource_type}
      module Authentication   # {class_path
        class OAuth2          #  class_path/file_name}
        end
      end
    end
  end
 end
```

As long as some part of the fully qualified class name (in this example: `Api::V3::UserServices::Authentication::OAuth2`) contains any of the [defined keywords](https://github.com/NullVoxPopuli/drawers/blob/master/lib/drawers/active_support/dependency_extensions.rb#L4), the file will be found at `app/resources/api/v3/users/services/authentication/oauth2.rb`.

The pattern for this is: `app/resources/:namespace/:resource_name/:resource_type/:class_path` where:
 - `:namespace` is the namespace/parents of the `UserService`
 - `:resource_type` is a suffix that may be inferred by checking of the inclusion of the defined keywords (linked above)
 - `:resource_name` is the same module/class as what the `resource_type` is derived from, sans the `resource_type`
 - `:class_path` is the remaining namespaces and eventually the class that the target file defines.

So... what if you have a set of classes that don't fit the pattern exactly? You can leave those files where they are currently, or move them to `app/resources`, if it makes sense to do so. Feel free to open an issue / PR if you feel the list of resource types needs updating.

## Usage

```ruby
gem 'drawers'
```

Including the gem in your gemfile enables the new structure.

### A note for ActiveModelSerializers

ActiveModelSerializers, be default, does not consider your _controller's_ namespace when searching for searializers.

To address that problem, you'll need to add this to the serializer lookup chain

```ruby
# config/initializers/active_model_serializers.rb
ActiveModelSerializers.config.serializer_lookup_chain.unshift(
  lambda do |resource_class, _, namespace|
    "#{namespace.name}::#{resource_class.name}Serializer" if namespace
  end
)
```
Note: as of 2016-11-04, only [this branch of AMS](https://github.com/rails-api/active_model_serializers/pull/1757) supports a confnigurable lookup chain

Note: as of 2016-11-16, the `master` (>= v0.10.3) branch of AMS supports configurable lookup chain.

## Migrating

Each part of your app can be migrated gradually (either manually or automatically).

In order to automatically migrate resources, just run:

```bash
rake rmu:migrate_resource[Post]
```

This will move all unnamespaced classes that contain any of the [supported resource suffixes](https://github.com/NullVoxPopuli/drawers/blob/master/lib/drawers/active_support_extensions.rb#L4) to the `app/resources/posts` directory.

## Configuration

```ruby
# (Rails.root)/config/initializers/drawers.rb
Drawers.directory = 'pods'
```

Sets the folder for the new structure to be in the `app/pods` directory if you want the new structure separate from the main app files.

## Contributing

Feel free to open an issue, or fork and make a pull request.

All discussion is welcome :-)


---------------

The gem name 'Drawers' was provided by @bartboy011.
Thanks @bartboy011!

The previous name of this gem was Rails Module Unification -- which, while a homage to its inspiration, Ember's Module Unification app architecture, it's quite a mouthful, and doesn't exactly make for a good gem name.
