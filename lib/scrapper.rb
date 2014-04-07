module Scrapper
  def self.tracking_number(filename)
    filename.split("/")[-1].split(".")[0]
  end

  def self.call
    total_documents = EmissionDownloaded.done.count
    per_page = 100.0
    total_pages = (total_documents/per_page).ceil
    pbar = ProgressBar.new("Importing", total_documents)
    total_pages.times.each do |page|
      EmissionDownloaded.done.limit(per_page).skip(page*per_page).each do |ed|
        extracted_event = EmissionEventExtractor.new(ed.content, ed.tracking_number).call
        emission_event = EmissionEvent.store(extracted_event)
        EmissionSource.store(extracted_event, emission_event)
        logger.info("Scrapping #{ed.tracking_number}")
        pbar.inc
      end
    end
    puts "#{total_documents} files has been imported"
  end
end
