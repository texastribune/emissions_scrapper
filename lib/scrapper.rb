module Scrapper
  def self.tracking_number(filename)
    filename.split("/")[-1].split(".")[0]
  end

  def self.call
    total_documents = PageHTML.non_scrapped_count
    per_page = 100
    total_pages = (total_documents/per_page.to_f).ceil
    pbar = ProgressBar.new("Importing", total_documents)
    logger.info("Starting scrapping process for #{total_documents} documents")
    total_pages.times.each do |page|
      PageHTML.non_scrapped_paginate(page + 1, per_page).each do |page|
        extracted_event = EmissionEventExtractor.new(page.content, page.tracking_number).call
        sources = extracted_event.delete(:sources)
        emission_event = EmissionEvent.store(extracted_event[:emission_table])
        # EmissionSource.store(extracted_event, emission_event)
        page.scrapped!
        logger.info("Scrapping #{page.tracking_number}")
        pbar.inc
      end
    end
    puts "#{total_documents} files has been imported"
  end
end
