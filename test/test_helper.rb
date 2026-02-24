# Load Redmine's test helper from the host application.
# When running plugin tests, REDMINE_ROOT should point to the Redmine installation.
redmine_root = ENV['REDMINE_ROOT'] || File.expand_path('../../../../', __dir__)
require File.join(redmine_root, 'test', 'test_helper')
