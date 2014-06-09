class EmissionEventExtractor
  class NoTable < StandardError
    attr_reader :object
    def initialize(object, message="")
      super("#{object.tracking_number} - #{message}")
      @object = object
    end
  end

  def self.columns
    %w(regulated_entity_name
      physical_location
      regulated_entity_rn_number
      city_county
      type_of_air_emission_event
      event_began
      this_is_based_on_the
      event_ended
      cause
      action_taken
      emissions_estimation_method
      tracking_number
      )
  end

  attr_reader :doc, :tracking_number

  def initialize(html, tracking_number)
    @tracking_number = tracking_number
    @doc = Nokogiri::HTML(html)
    @output = {sources: []}
  end

  def call
    table = doc.css('table').first

    raise NoTable.new(self, 'No table') if table.nil?

    @output[:emission_table] = extract_emission_table(table)

    sources = []
    doc.css('h3').each do |source_title|
      source = {name: clean_text(source_title)}
      if source_title.next.name == "table"
        source[:source_table] = extract_source_table(
          source_title.next)
      end
      sources << source
    end
    @output[:sources] = sources
    @output
  end

  def extract_emission_table(table)
    output = {}
    tds = table.css("td")
    tds.each_with_index do |td, index|
      output[columns[index]] = clean_text(td)
    end
    output[:tracking_number] = @tracking_number
    output
  end

  def extract_source_table(table)
    trs = table.css('tr')[1..-1]
    output = {
      contaminant: [],
      authorization: [],
      limit: [],
      amount_released: []
    }
    trs.each do |tr|
      tds = tr.css('td')
      output[:contaminant] << clean_text(tds[0])
      output[:authorization] << clean_text(tds[1])
      output[:limit] << clean_text(tds[2])
      output[:amount_released] << clean_text(tds[3])
    end
    output
  end

  def clean_text(element)
    element.text.gsub(/\s+/, " ").strip.downcase
  end

  def columns
    self.class.columns
  end
end
