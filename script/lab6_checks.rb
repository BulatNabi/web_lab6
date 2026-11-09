# Small helpers for the chapter 6 console exercises (script/lab6_*.rb).
# check compares a result with the expected value: prints "ok" or stops with "FAIL".

@checks = 0

def section(title)
  puts
  puts "== #{title} =="
end

def check(label, actual, expected)
  unless actual == expected
    abort "FAIL #{label}: expected #{expected.inspect}, got #{actual.inspect}"
  end

  @checks += 1
  puts "  ok  #{label}: #{actual.inspect}"
end

# Names of the class and all its superclasses, e.g. ["User", "ApplicationRecord", ...].
def class_chain(klass)
  chain = []
  while klass
    chain << klass.name
    klass = klass.superclass
  end
  chain
end

# Runs the block inside a transaction and always rolls it back, like `rails console --sandbox`.
# The users table is emptied first (inside the transaction), so the checks do not depend on
# records that already exist in the development database.
def sandbox
  ActiveRecord::Base.transaction do
    User.delete_all
    yield
    raise ActiveRecord::Rollback
  end
end

def finish(name)
  puts
  puts "#{name}: #{@checks} checks passed."
end
