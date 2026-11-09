# Sections 6.1.2-6.1.5 and 6.2.1: working with User objects. Everything is rolled back at the end.
#   bin/rails runner script/lab6_objects.rb
# The checks describe the finished app: a user needs a password, so every record below has one
# (at the commit "Add the User model" the same steps worked with just name and email).
require_relative "lab6_checks"

PASSWORD = "secret1".freeze

section "6.1.2 The model file"
check("User hierarchy", class_chain(User), %w[User ApplicationRecord ActiveRecord::Base Object BasicObject])
check("ApplicationRecord superclass", ApplicationRecord.superclass.name, "ActiveRecord::Base")

sandbox do
  section "6.1.3 Creating user objects"
  blank = User.new
  check("User.new has no attributes", [ blank.name, blank.email, blank.id ], [ nil, nil, nil ])
  check("user without a password is not valid", blank.valid?, false)
  anna = User.new(name: "Anna Example", email: "anna@example.com", password: PASSWORD, password_confirmation: PASSWORD)
  check("new user with a password is valid", anna.valid?, true)
  check("new user is not in the database", anna.persisted?, false)
  check("save returns true", anna.save, true)
  check("save assigns an id", anna.id.is_a?(Integer), true)
  check("name and email are Strings", [ anna.name.class, anna.email.class ], [ String, String ])
  check("magic columns are time objects", [ anna.created_at.class, anna.updated_at.class ],
        [ ActiveSupport::TimeWithZone, ActiveSupport::TimeWithZone ])
  check("created_at equals updated_at after the first save", anna.created_at == anna.updated_at, true)

  boris = User.create(name: "Boris Test", email: "boris@example.org", password: PASSWORD, password_confirmation: PASSWORD)
  check("create returns the User object", boris.class.name, "User")
  check("destroy returns the object", boris.destroy.equal?(boris), true)
  check("destroyed object stays in memory", [ boris.destroyed?, boris.name ], [ true, "Boris Test" ])

  section "6.1.4 Finding user objects"
  check("find by id", User.find(anna.id).id, anna.id)
  check("find of a destroyed id raises", (User.find(boris.id) rescue $!.class), ActiveRecord::RecordNotFound)
  check("find_by email", User.find_by(email: "anna@example.com").id, anna.id)
  check("find_by name", User.find_by(name: "Anna Example").id, anna.id)
  check("find_by_name works too", User.find_by_name("Anna Example").id, anna.id)
  check("first", User.first.id, anna.id)
  check("all is a relation", User.all.class.to_s, "User::ActiveRecord_Relation")
  check("all can be measured like an array", User.all.length, 1)

  section "6.1.5 Updating user objects"
  anna.name = "Anna Sample"
  check("assignment and save", [ anna.save, anna.reload.name ], [ true, "Anna Sample" ])
  check("update", [ anna.update(name: "Anna Updated", email: "updated@example.com"), anna.reload.email ],
        [ true, "updated@example.com" ])
  anna.email = "unsaved@example.com"
  check("reload discards unsaved changes", anna.reload.email, "updated@example.com")
  check("update_attribute", [ anna.update_attribute(:name, "Anna Final"), anna.reload.name ], [ true, "Anna Final" ])
  year_ago = 1.year.ago
  anna.created_at = year_ago
  anna.save
  check("created_at can be changed", anna.reload.created_at.to_i, year_ago.to_i)
  check("created_at no longer equals updated_at", anna.created_at == anna.updated_at, false)

  section "6.2.1 A validity test"
  check("a saved user is valid", anna.valid?, true)
end

check("everything was rolled back", User.where(email: [ "anna@example.com", "updated@example.com" ]).count, 0)
finish "lab6_objects"
