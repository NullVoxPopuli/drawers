# frozen_string_literal: true
require 'spec_helper'

require 'rails/all'

require 'factory_girl'
require 'factory_girl_rails'
require 'rspec/rails'

require 'support/rails_app/config/environment'

ActiveRecord::Migration.maintain_test_schema!

require 'support/rails_app/db/create'

require 'support/rails_app/factory_girl'
# require 'support/rails_app/factories'
