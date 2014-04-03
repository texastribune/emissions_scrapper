require 'csv'

class EmissionCSV
  def self.call
    self.new.call
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
  end

  def filename
    "#{APP_ROOT}/output_#{Time.now.to_i}.csv"
  end

  def titles
    EmissionEvent.fields.keys.map(&:titleize)
  end

  def fields
    EmissionEvent.fields.keys.map(&:to_sym)
  end
end
