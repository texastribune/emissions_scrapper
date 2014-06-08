class Filer
  def self.call(from, to)
    self.new(from, to).call
  end

  def initialize(from, to)
    @from = from
    @to = to
  end

  def call
    slices = (@from..@to).each_slice(10)
    slices.each do |slice|
      threads = []
      pages = []
      slice.each do |tracking_number|
        threads << Thread.new do
          pages << PageDownloader.new(tracking_number).call
        end
      end
      threads.each { |t| t.join }
      store(pages)
    end
  end

  def store(pages)
    pages.each do |page|
      next if page.status == 'failed'

      File.open("output/#{page.tracking_number}.html", 'w') do |file|
        file.write(page.content)
      end
    end
  end
end

__END__

bin/scraper files 118000 118100