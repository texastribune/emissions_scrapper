class Scraper
  def initialize(options={})
    if options[:latest]
      populate_from_to
    else
      @from = options[:from]
      @to = options[:to]
    end
  end

  def populate_from_to
    last_downloaded = PageHTML.last
    @from = last_downloaded
    @to = last_downloaded + 100
  end

  def call
    download_to_db(@from, @to)
    scraping
  end

  def download_to_db(from, to)
    logger.info("Downloading HTML #{from}/#{to}")

    slices = (from..to).each_slice(40)
    pbar = ProgressBar.new("Sync", slices.count)
    slices.each do |slice|
      threads = []
      pages = []
      slice = slice.map(&:to_i)
      PageHTML.not_downloaded_batch(slice).
        each do |tracking_number|
        threads << Thread.new do
          pages << PageDownloader.new(tracking_number).call
        end
      end
      threads.each { |t| t.join }
      downloaded_pages = pages.select { |page|
        page.status == "done"
      }.map(&:to_hash)
      PageHTML.insert(downloaded_pages)
      logger.info(
        "#{downloaded_pages.length} pages has been stored"
      )
      pbar.inc
    end
  end

  def scraping
    total_documents = PageHTML.non_scrapped_count
    per_page = 100
    total_pages = (total_documents/per_page.to_f).ceil
    pbar = ProgressBar.new("Importing", total_documents)
    logger.info("Starting scrapping process for #{total_documents} documents")
    total_pages.times.each do |page|
      PageHTML.non_scrapped_paginate(page + 1, per_page).each do |page|
        begin
          extracted_event = EmissionEventExtractor.new(page.content, page.tracking_number).call
        rescue EmissionEventExtractor::NoTable => e
          logger.info("#{e.message}")
          next
        end
        sources = extracted_event.delete(:sources)
        emission_event = EmissionEvent.store(extracted_event[:emission_table])
        page.scrapped!
        logger.info("Scrapping #{page.tracking_number}")
        pbar.inc
      end
    end
    puts "#{total_documents} files has been imported"
  end
end
