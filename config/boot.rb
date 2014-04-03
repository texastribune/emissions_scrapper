require 'rubygems' unless defined?(Gem)
require 'bundler/setup'
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

Mongoid.load!("config/mongoid.yml", :development)

Dir["#{APP_ROOT}/lib/**/*.rb"].sort.each {|file| require file}
Dir["#{APP_ROOT}/models/**/*.rb"].sort.each {|file| require file}
