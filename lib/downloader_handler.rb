class DownloaderHandler
  attr_accessor :threads_count

  def self.call(from, to, opt={})
    threads_count = opt.fetch(:threads_count, 20)
    self.new(threads_count).download(from, to)
  end

  def initialize(threads_count = 20)
    @threads_count = threads_count
  end

  def execute(batch)
    threads = []
    pages_content = []
    batch.each do |page_id|
      threads << Thread.new do
        pages_content << {page_id: page_id, content: PageDownloader.get(page_id)}
      end
    end
    threads.each { |t| t.join }
    Page.bulk(pages_content)
  end

  def download(from=10000, to=20000)
    batch = []
    (from..to).each do |page_id|
      unless Page.downloaded?(page_id)
        batch << page_id
      end
      if batch.length == threads_count
        execute(batch)
        batch = []
      end
    end
    execute(batch) # Will execute the last batch
  end
end
