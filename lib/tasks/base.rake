task :environment do
  require File.expand_path("../../../config/boot.rb", __FILE__)
end

desc "Fire up a console"
task console: :environment do
  require "pry"
  Pry.config.prompt = [
    proc { "emissions> " }
  ]
  binding.pry(quiet: true)
end
