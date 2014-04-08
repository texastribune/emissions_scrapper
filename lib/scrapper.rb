module Scrapper
  def self.tracking_number(filename)
    filename.split("/")[-1].split(".")[0]
  end

  def self.call
    total_documents = PageHTML.non_scrapped.count
    per_page = 100.0
    total_pages = (total_documents/per_page).ceil
    pbar = ProgressBar.new("Importing", total_documents)
    logger.info("Starting scrapping process for #{total_documents} documents")
    total_pages.times.each do |page|
      PageHTML.non_scrapped.limit(per_page).skip(page*per_page).each do |page|
        extracted_event = EmissionEventExtractor.new(page.content, page.tracking_number).call
        emission_event = EmissionEvent.store(extracted_event)
        EmissionSource.store(extracted_event, emission_event)
        page.update_attribute(:scrapped, true)
        logger.info("Scrapping #{page.tracking_number}")
        pbar.inc
      end
    end
    puts "#{total_documents} files has been imported"
  end
end
