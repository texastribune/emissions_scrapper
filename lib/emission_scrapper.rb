module EmissionScrapper
  def download(from=10000, to=20000)
    logger.info("Files syncronization #{from}/#{to}")

    threads = []
    slices = (from..to).each_slice(20)
    pbar = ProgressBar.new("Sync", slices.count)
    slices.each do |slice|
      slice.each do |tracking_number|
        threads << Thread.new do
          EmissionDownloader.new(tracking_number).call
        end
      end
      threads.each { |t| t.join }
      pbar.inc
    end
  end
  module_function :download
end
