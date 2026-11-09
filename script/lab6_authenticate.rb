# Section 6.3.4, step 2: run in a NEW process after lab6_create_user.rb, so the user is found
# in the database and not in memory. Changes the user's name, as exercise 6.3.4.3 asks.
#   bin/rails runner script/lab6_authenticate.rb
require_relative "lab6_checks"

NEW_NAME = ENV.fetch("LAB6_NAME", "Bulat Nabiullin")

section "6.3.4 Authenticating a user"
account = User.find_by(email: "michael@example.com")
abort "Run script/lab6_create_user.rb first" unless account

check("user is found after a restart", account.email, "michael@example.com")
check("wrong password", account.authenticate("not_the_right_password"), false)
check("another wrong password", account.authenticate("foobaz"), false)
check("right password returns the user", account.authenticate("foobar") == account, true)
check("!! turns the result into true", !!account.authenticate("foobar"), true)
check("the password is not kept after loading", account.password, nil)

section "6.3.4 exercises"
account.name = NEW_NAME
check("save fails: a loaded user has no password", account.save, false)
check("the reason is the password validation", account.errors[:password].any?, true)
check("update_attribute skips the validations", account.update_attribute(:name, NEW_NAME), true)
check("the new name is in the database", User.find(account.id).name, NEW_NAME)
finish "lab6_authenticate"
