require 'active_record'
require 'sqlite3'

# Change the following to reflect your database settings
ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database:     ':memory:'
)

# Don't show migration output when constructing fake db
ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :authors, force: true do |t|
    t.string :name
  end

  create_table :posts, force: true do |t|
    t.text :body
    t.string :title
    t.references :author
  end

  create_table :profiles, force: true do |t|
    t.text :project_url
    t.text :bio
    t.date :birthday
    t.references :author
  end
end
