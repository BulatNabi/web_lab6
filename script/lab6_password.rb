# Sections 6.3.2-6.3.3: has_secure_password and the minimum password standards.
#   bin/rails runner script/lab6_password.rb
require_relative "lab6_checks"

sandbox do
  section "6.3.2 has_secure_password"
  nobody = User.new(name: "Olga Sample", email: "olga@example.com")
  check("valid name and email are not enough", nobody.valid?, false)
  check("a missing password is reported", nobody.errors[:password].include?("can't be blank"), true)
  check("password and confirmation are virtual attributes", User.column_names.include?("password"), false)
  check("only the digest is stored", User.column_names.include?("password_digest"), true)

  section "6.3.3 Minimum password standards"
  short = User.new(name: "Olga Sample", email: "olga@example.com", password: "abcde", password_confirmation: "abcde")
  check("5 characters are not enough", short.valid?, false)
  check("too short message", short.errors.full_messages, [ "Password is too short (minimum is 6 characters)" ])
  six = User.new(name: "Olga Sample", email: "olga@example.com", password: "abcdef", password_confirmation: "abcdef")
  check("6 characters are enough", six.valid?, true)
  spaces = User.new(name: "Olga Sample", email: "olga@example.com", password: " " * 6, password_confirmation: " " * 6)
  check("6 spaces are not a password", spaces.valid?, false)
  mismatch = User.new(name: "Olga Sample", email: "olga@example.com", password: "abcdef", password_confirmation: "abcdeg")
  check("a different confirmation is rejected", mismatch.valid?, false)
  check("confirmation message", mismatch.errors.full_messages, [ "Password confirmation doesn't match Password" ])
  huge = User.new(name: "Olga Sample", email: "olga@example.com", password: "a" * 73, password_confirmation: "a" * 73)
  check("bcrypt allows at most 72 bytes", huge.valid?, false)
  check("72 bytes are fine", User.new(name: "Olga Sample", email: "olga@example.com", password: "a" * 72, password_confirmation: "a" * 72).valid?, true)

  section "6.3.4 The digest"
  six.save
  check("the digest is a 60 character bcrypt hash", [ six.password_digest.length, six.password_digest.start_with?("$2a$") ], [ 60, true ])
  check("the digest is not the password", six.password_digest == "abcdef", false)
  check("authenticate with the right password", six.authenticate("abcdef") == six, true)
  check("authenticate with a wrong password", six.authenticate("abcdeg"), false)
end

finish "lab6_password"
