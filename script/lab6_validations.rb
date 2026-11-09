# Sections 6.2.2-6.2.5: presence, length, format and uniqueness of name and email.
#   bin/rails runner script/lab6_validations.rb
require_relative "lab6_checks"

def valid_user(attributes = {})
  User.new({ name: "Nina Sample", email: "nina@example.com",
             password: "secret1", password_confirmation: "secret1" }.merge(attributes))
end

sandbox do
  section "6.2.2 Presence"
  empty = User.new
  check("empty user is invalid", empty.valid?, false)
  check("name errors", empty.errors[:name], [ "can't be blank" ])
  check("errors.messages is a Hash", empty.errors.messages.class, Hash)
  check("email errors via messages", empty.errors.messages[:email], [ "can't be blank", "is invalid" ])
  check("email errors via errors[]", empty.errors[:email], [ "can't be blank", "is invalid" ])
  check("blank string of spaces is not present", valid_user(name: "     ").valid?, false)
  check("invalid user is not saved", valid_user(name: "").save, false)

  section "6.2.3 Length"
  check("string multiplication", ("a" * 51).length, 51)
  check("too long email is 256 characters", ("a" * 244 + "@example.com").length, 256)
  long = valid_user(name: "a" * 51, email: "a" * 244 + "@example.com")
  check("too long name and email are invalid", long.valid?, false)
  check("length messages", long.errors.full_messages,
        [ "Name is too long (maximum is 50 characters)", "Email is too long (maximum is 255 characters)" ])
  check("limits themselves are valid", valid_user(name: "a" * 50, email: "a" * 243 + "@example.com").valid?, true)

  section "6.2.4 Format"
  good = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
  bad  = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com foo@bar..com]
  good.each { |address| check("accepts #{address}", valid_user(email: address).valid?, true) }
  bad.each  { |address| check("rejects #{address}", valid_user(email: address).valid?, false) }
  check("format message", valid_user(email: "user_at_foo.org").tap(&:valid?).errors.full_messages, [ "Email is invalid" ])
  # Exercises 6.2.4.1 and 6.2.4.3 (Rubular): the same regexes matched in plain Ruby.
  basic = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  check("listing 6.21 wrongly matches foo@bar..com", bad.select { |address| address.match?(basic) }, [ "foo@bar..com" ])
  check("listing 6.23 matches every valid address", good.all? { |address| address.match?(User::VALID_EMAIL_REGEX) }, true)
  check("listing 6.23 matches no invalid address", bad.any? { |address| address.match?(User::VALID_EMAIL_REGEX) }, false)

  section "6.2.5 Uniqueness"
  first = valid_user
  check("first user saves", first.save, true)
  same = first.dup
  check("duplicate email is invalid", same.valid?, false)
  check("duplicate message", same.errors.full_messages, [ "Email has already been taken" ])
  shouting = first.dup
  shouting.email = first.email.upcase
  check("duplicate in upper case is invalid", shouting.valid?, false)
  check("database index rejects a duplicate even without validations",
        (same.save(validate: false) rescue $!.class), ActiveRecord::RecordNotUnique)
  mixed = valid_user(email: "Foo@ExAMPle.CoM")
  mixed.save
  check("email is saved in lowercase", mixed.reload.email, "foo@example.com")
  check("a unique index exists", ActiveRecord::Base.connection.indexes(:users).map { |index| [ index.columns, index.unique ] },
        [ [ [ "email" ], true ] ])
end

finish "lab6_validations"
