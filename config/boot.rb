APP_ENV = ENV['APP_ENV'] ||= "development" unless defined?(APP_ENV)

require 'rubygems' unless defined?(Gem)
require 'bundler/setup'
require 'yaml'
require 'active_support/inflector'

APP_ROOT = File.expand_path("../..", __FILE__)
TMP_DIR = "#{APP_ROOT}/tmp"

$LOAD_PATH.unshift(APP_ROOT)
Bundler.require(:default)

LOGGER = Logger.new("#{APP_ROOT}/log/emissions.log")

module Kernel
  def logger
    LOGGER
  end
end

Mongoid.load!("config/mongoid.yml", APP_ENV)

Dir["#{APP_ROOT}/lib/**/*.rb"].sort.each {|file| require file}
Dir["#{APP_ROOT}/models/**/*.rb"].sort.each {|file| require file}
