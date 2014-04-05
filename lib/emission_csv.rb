require 'csv'

class EmissionCSV
  def self.call(version=:short)
    if version == :full
      self.new.call(:full)
    else
      self.new.call
    end
  end

  def initialize(version=:short)
    @full = version == :full ? true : false
  end

  def call
    pbar = ProgressBar.new("Exporting", EmissionEvent.count)
    CSV.open(filename, 'wb') do |csv|
      csv << titles
      EmissionEvent.all.each do |emission_event|
        csv << fields.map { |field| emission_event.send(field) }
        pbar.inc
      end
    end
    puts "#{filename} has been generated"
  end

  def filename
    "#{APP_ROOT}/output_#{Time.now.to_i}.csv"
  end

  def titles
    if @full
      full_fields(&:titleize)
    else
      short_fields.map(&:titleize)
    end
  end

  def fields
    if @full
      full_fields.map(&:to_sym)
    else
      short_fields(&:to_sym)
    end
  end

  def full_fields
    EmissionEvent.fields.keys
  end

  def short_fields
    full_fields - removed
  end

  def removed
    %w(
      physical_location
      city_county
      type_of_air_emission_event
      cause
      action_taken
      emissions_estimation_method
    )
  end
end
