# rails_module_unification
Ember's module unification brought to Rails.

[![Gem Version](https://badge.fury.io/rb/rails_module_unification.svg)](https://badge.fury.io/rb/rails_module_unification)
[![Build Status](https://travis-ci.org/NullVoxPopuli/rails_module_unification.svg?branch=master)](https://travis-ci.org/NullVoxPopuli/rails_module_unification)
[![Code Climate](https://codeclimate.com/repos/57dddb2c50dac40e6900197c/badges/73a0a0761e417c655b68/gpa.svg)](https://codeclimate.com/repos/57dddb2c50dac40e6900197c/feed)
[![Test Coverage](https://codeclimate.com/repos/57dddb2c50dac40e6900197c/badges/73a0a0761e417c655b68/coverage.svg)](https://codeclimate.com/repos/57dddb2c50dac40e6900197c/coverage)
[![Dependency Status](https://gemnasium.com/badges/github.com/NullVoxPopuli/rails_module_unification.svg)](https://gemnasium.com/github.com/NullVoxPopuli/rails_module_unification)


## What is this about?

With large rails application, the default architecture can result in a resource's related files being very spread out through the overall project structure. For example, lets say you have 50 controllers, serializers, policies, and operations. That's _four_ different top level folders that spread out all the related objects. It makes sense do it this way, as it makes rails' autoloading programmatically easy.

This gem provides a way to re-structure your app so that like-objects are grouped together.

### The new structure

```
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
    │   ├── controller.rb
    │   ├── operation.rb
    │   ├── policy.rb
    │   └── serializer.rb
    └── comments/
        ├── controller.rb
        ├── serializer.rb
        └── views/
            ├── index.html.erb
            └── create.html.erb

```

[Checkout the sample rails app in the tests directory.](https://github.com/NullVoxPopuli/rails_module_unification/tree/master/spec/support/rails_app/app)

## Usage

```ruby
gem 'rails_module_unification'
```

Including the gem in your gemfile enables the new structure.

## Migrating

Each part of your app can be migrated gradually (either manually or automatically).

In order to automatically migrate resources, just run:

```bash
rake rmu:migrate_resource[Post]
```

This will move all unnamespaced classes that contain any of the [supported resource suffixes](https://github.com/NullVoxPopuli/rails_module_unification/blob/master/lib/rails_module_unification/active_support_extensions.rb#L4) to the `app/resources/posts` directory.

## Configuration

```ruby
# (Rails.root)/config/initializers/rails_module_unification.rb
RailsModuleUnification.directory = 'pods'
```

Sets the folder for the new structure to be in the `app/pods` directory if you want the new structure separate from the main app files.

## Contributing

Feel free to open an issue, or fork and make a pull request.

All discussion is welcome :-)
