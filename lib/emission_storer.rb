module EmissionStorer
  def self.start
    EmissionEvent.destroy_all
    EmissionSource.destroy_all
    range = 10001..20000
    pbar = ProgressBar.new("Importing", 10000)
    i = 0
    range.each do |tracking_number|
      filename = "#{TMP_DIR}/#{tracking_number}.html"
      if File.exists?(filename)
        File.open(filename) do |file|
          html = file.read
          extracted_event = EmissionEventExtractor.new(html, tracking_number).call
          emission_event = EmissionEvent.store(extracted_event)
          EmissionSource.store(extracted_event, emission_event)
          i = i + 1
          logger.info("Scrapping #{filename.split("/")[-1]}")
        end
      end
      pbar.inc
    end
    puts "#{i} files has been imported"
  end
end
