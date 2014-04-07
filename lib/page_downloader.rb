class PageDownloader
  Page = Struct.new(:status, :content, :tracking_number) do
    def to_hash
      {
        status: self.status,
        tracking_number: self.tracking_number,
        content: self.content
      }
    end
  end

  attr_reader :tracking_number

  def initialize(tracking_number)
    @tracking_number = tracking_number
  end

  def call
    content = ""
    status = "done"
    begin
      content = open(url(tracking_number)).read
      logger.info("#{tracking_number} has been downloaded")
    rescue OpenURI::HTTPError, Timeout::Error, SocketError, Errno::ECONNRESET => e
      content = e.message
      status = "failed"
      logger.error("#{tracking_number} failed with #{e.message}")
    end
    Page.new(status, content, tracking_number)
  end

  def url(tracking_number)
    "http://www11.tceq.texas.gov/oce/eer/index.cfm?fuseaction=main.getDetails&target=#{tracking_number}"
  end
end
