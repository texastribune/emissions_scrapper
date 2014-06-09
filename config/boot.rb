APP_ENV = ENV["APP_ENV"] ||= "development" unless defined?(APP_ENV)

APP_ROOT = File.expand_path("../..", __FILE__)
TMP_DIR = "#{APP_ROOT}/tmp"

require 'rubygems' unless defined?(Gem)
require 'bundler/setup'
require 'yaml'
require 'sequel'

$LOAD_PATH.unshift(APP_ROOT)
Bundler.require(:default)

LOGGER = Logger.new("#{APP_ROOT}/log/emissions.log")
if APP_ENV == "production"
  LOGGER.level = Logger::DEBUG
else
  LOGGER.level = Logger::ERROR
end

module Kernel
  def logger
    LOGGER
  end
end

database_config = YAML.load_file('config/database.yml')
DB = Sequel.connect(database_config[APP_ENV])
DB.loggers << logger

Dir["#{APP_ROOT}/lib/**/*.rb"].sort.each {|file| require file}
Dir["#{APP_ROOT}/models/**/*.rb"].sort.each {|file| require file}
