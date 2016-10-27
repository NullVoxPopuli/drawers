class Author < ApplicationRecord
  has_many :posts, class_name: Post.name
end
