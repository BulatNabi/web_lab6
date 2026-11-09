require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = "     "
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = "     "
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com foo@bar..com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email addresses should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "database rejects duplicate emails even without validations" do
    @user.save
    duplicate_user = @user.dup
    assert_raises(ActiveRecord::RecordNotUnique) do
      duplicate_user.save(validate: false)
    end
  end

  test "email addresses should be saved as lowercase" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test "password confirmation should match" do
    @user.password_confirmation = "different"
    assert_not @user.valid?
  end

  test "password cannot exceed the bcrypt limit of 72 bytes" do
    @user.password = @user.password_confirmation = "a" * 73
    assert_not @user.valid?
  end

  test "six character password is valid" do
    @user.password = @user.password_confirmation = "a" * 6
    assert @user.valid?
  end

  test "maximum allowed lengths should be valid" do
    @user.name = "a" * 50
    @user.email = "a" * 243 + "@example.com"
    assert @user.valid?
  end

  test "authentication accepts only the correct password" do
    @user.save
    user = User.find(@user.id)
    assert_equal user, user.authenticate("foobar")
    assert_equal true, !!user.authenticate("foobar")
    assert_equal false, user.authenticate("foobaz")
    assert_equal false, user.authenticate("not_the_right_password")
    assert_not_equal "foobar", user.password_digest
    assert BCrypt::Password.new(user.password_digest).is_password?("foobar")
  end

  test "a loaded user needs a password to save, update_attribute skips validations" do
    @user.save
    user = User.find(@user.id)
    user.name = "New Name"
    assert_not user.save
    assert_includes user.errors[:password], "can't be blank"
    assert user.update_attribute(:name, "Updated Name")
    assert_equal "Updated Name", user.reload.name
  end
end
