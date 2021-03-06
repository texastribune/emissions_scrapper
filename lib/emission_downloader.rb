require 'open-uri'

class EmissionDownloader
  attr_accessor :tracking_number
  def initialize(tracking_number)
    @tracking_number = tracking_number
    @filename = "#{tracking_number}.html"
  end

  def call
    if already_downloaded?
      logger.info("#{filename} already downloaded.")
    else
      download_file
    end
  end

  def already_downloaded?
    EmissionDownloaded.downloaded?(tracking_number)
  end

  def download_file
    html = ""
    begin
      html = open("http://www11.tceq.texas.gov/oce/eer/index.cfm?fuseaction=main.getDetails&target=#{tracking_number}").read
      logger.info("Downloading #{filename.split("/")[-1]} [#{html.size} bits]")
      File.open(filename, 'wb') do |file|
        file.write(html)
        store("done", html.size, html)
      end
    rescue OpenURI::HTTPError, Timeout::Error, SocketError, Errno::ECONNRESET => e
      store("failure", e.message)
      logger.error "#{filename.split("/")[-1]} could not be downloaded"
    end
  end

  def filename
    "#{TMP_DIR}/#{@filename}"
  end

  def store(status, desc, content="")
    EmissionDownloaded.store(tracking_number, status, desc, content)
  end
end
