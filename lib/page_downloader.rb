require 'open-uri'

class PageDownloader
  Content = Struct.new(:status, :content)

  attr_reader :tracking_number

  def self.get(page_id)
    self.new(page_id).call
  end

  def initialize(tracking_number)
    @tracking_number = tracking_number
  end

  def call
    content = begin
      html = open(uri(tracking_number)).read
      logger.info("Page #{tracking_number} stored. [#{html.size} bits]")
      Content.new(:ok, html)
    rescue OpenURI::HTTPError, Timeout::Error, SocketError, Errno::ECONNRESET => e
      logger.error("Page #{tracking_number} with error: #{e.message}")
      Content.new(:error, e.message)
    end
    content
  end

  def uri(tracking_number)
    "http://www11.tceq.texas.gov/oce/eer/index.cfm?fuseaction=main.getDetails&target=#{tracking_number}"
  end
end
