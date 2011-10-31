# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'

# http://stackoverflow.com/questions/6199301/global-access-to-rake-dsl-methods-is-deprecated
include Rake::DSL

Cooks::Application.load_tasks
