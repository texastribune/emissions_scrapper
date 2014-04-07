module Downloader
  def call
    logger.info("Files syncronization #{from}/#{to}")

    threads = []
    pages = []
    slices = (from..to).each_slice(40)
    pbar = ProgressBar.new("Sync", slices.count)
    slices.each do |slice|
      slice.each do |tracking_number|
        threads << Thread.new do
          pages << EmissionDownloader.new(tracking_number).call
        end
      end
      threads.each { |t| t.join }
      downloaded_pages = pages.select { |page| page.status == "done" }
      PageHTML.collection.insert(downloaded_pages)
      logger.info("#{downloaded_pages.length} pages has been stored")
      pages = []
      pbar.inc
    end
  end
  module_function :call
end


__END__

per_page = 100
total_emissions = EmissionDownloaded.count
total_pages = (EmissionDownloaded/per_page.to_f).ceil

batch = []
total_pages.times do |page|
  EmissionDownloaded.skip(per_page*page).limit(per_page).each do |ed|

  end
  batch = []
end