module EmissionStorer
  def self.tracking_number(filename)
    filename.split("/")[-1].split(".")[0]
  end

  def self.start
    i = 0
    EmissionEvent.destroy_all
    EmissionSource.destroy_all
    tracking_numbers = Dir["#{TMP_DIR}/*.html"].map {|filename| tracking_number(filename)}
    pbar = ProgressBar.new("Importing", tracking_numbers.length)
    tracking_numbers.each do |tracking_number|
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
