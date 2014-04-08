module Downloader
  def call(from, to)
    logger.info("Files syncronization #{from}/#{to}")

    slices = (from..to).each_slice(40)
    pbar = ProgressBar.new("Sync", slices.count)
    slices.each do |slice|
      threads = []
      pages = []
      PageHTML.not_downloaded_batch(slice).each do |tracking_number|
        threads << Thread.new do
          pages << PageDownloader.new(tracking_number).call
        end
      end
      threads.each { |t| t.join }
      downloaded_pages = pages.select { |page| page.status == "done" }.map(&:to_hash)
      PageHTML.collection.insert(downloaded_pages)
      logger.info("#{downloaded_pages.length} pages has been stored")
      pbar.inc
    end
  end
  module_function :call
end
