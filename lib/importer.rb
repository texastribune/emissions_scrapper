class Importer
  attr_reader :directory

  def initialize(options)
    @directory = options.fetch(:directory, 'output')
  end

  def call
    pbar = ProgressBar.new("Importing", files.length)
    files.each do |filename|
      tracking_number = filename.match(/(\d+)\.html/)[1].to_i
      File.open(filename) do |file|
        content = file.read
        PageHTML.insert content: content, tracking_number: tracking_number
      end
      pbar.inc
    end
  end

  def files
    Dir["#{File.join(directory, '*.html')}"]
  end
end