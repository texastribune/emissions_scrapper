require 'csv'

class Exporter
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
    total_emission_events = EmissionEvent.count
    per_page = 100
    total_pages = (total_emission_events/per_page.to_f).ceil

    pbar = ProgressBar.new("Exporting", total_pages)
    insert_titles

    total_pages.times.each do |page|
      CSV.open(filename, 'a') do |csv|
        EmissionEvent.limit(per_page).skip(page * per_page).each do |emission_event|
          csv << fields.map { |field| emission_event.send(field) }
        end
      end
      pbar.inc
    end

    puts "\n#{filename} has been generated"
  end

  def insert_titles
    CSV.open(filename, 'wb') do |csv|
      csv << titles
    end
  end

  def filename
    @filename ||= "#{APP_ROOT}/output_#{Time.now.to_i}.csv"
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
