# Section 6.3.4, step 1: create the book's user in the development database (not in a sandbox).
#   bin/rails runner script/lab6_create_user.rb
# Safe to run again: the record is found by email and updated instead of duplicated.
require_relative "lab6_checks"

account = User.find_or_initialize_by(email: "michael@example.com")
account.assign_attributes(name: "Michael Hartl", password: "foobar", password_confirmation: "foobar")
account.save!

section "6.3.4 Creating a user"
check("the user is saved", account.persisted?, true)
check("the email is stored in lowercase", account.email, "michael@example.com")
check("the digest is a bcrypt hash", account.password_digest.start_with?("$2a$", "$2b$"), true)
check("exactly one row has this email", User.where(email: "michael@example.com").count, 1)
finish "lab6_create_user"
