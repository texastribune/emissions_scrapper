class EmissionEvent
  include Mongoid::Document
  field :regulated_entity_name, type: String
  field :physical_location, type: String
  field :regulated_entity_rn_number, type: String
  field :city_county, type: String
  field :type_of_air_emission_event, type: String
  field :event_began, type: String
  field :event_ended, type: String
  field :this_is_based_on_the, type: String
  field :cause, type: String
  field :action_taken, type: String
  field :emissions_estimation_method, type: String
  field :city, type: String
  field :county, type: String
  field :tracking_number, type: Integer

  field :event_began_time, type: DateTime
  field :event_ended_time, type: DateTime
  field :event_duration, type: Float
  field :city, type: String
  field :county, type: String

  has_many :emission_sources
  validates_presence_of :tracking_number
  validates_uniqueness_of :tracking_number

  before_create :store_numeric_values

  def self.store(extracted_event)
    emission_event = self.new
    extracted_event[:emission_table].each do |key, value|
      emission_event.write_attribute(key.to_sym, value)
    end
    emission_event.save
    emission_event
  end

  def store_numeric_values
    self.event_began_time = convert_time(self.event_began)
    self.event_ended_time = convert_time(self.event_ended)
    self.event_duration = ((self.event_ended_time -
                            self.event_began_time)/60/60)
    write_attribute(:city, find_city(self.city_county))
    write_attribute(:county, find_county(self.city_county))
  end

  def find_city(city_county_str)
    if city_county_str.split(',')[0]
      city_county_str.split(',')[0].strip
    else
      ""
    end
  end

  def find_county(city_county_str)
    if city_county_str.split(',')[1]
      city_county_str.split(',')[1].strip
    else
      ""
    end
  end

  def convert_time(str)
    begin
      if str.split.length > 1
        Time.strptime(str, "%m/%d/%Y %I:%M %P")
      else
        Time.strptime(str, "%m/%d/%Y")
      end
    rescue ArgumentError
      puts "WRONG #{str}"
      Time.now
    end
  end
end
