class EmissionEvent < Sequel::Model
  def self.count
    dataset.count
  end

  def self.paginate(page, per_page=100)
    dataset.order(:event_began_time).limit(per_page).offset(page * per_page)
  end

  def self.store(attr)
    emission_event = self.new(attr)
    emission_event.save
    emission_event
  end

  def self.fields
    self.columns - [:page_html_id]
  end

  def before_create
    self.event_began_time = convert_time(self.event_began)
    self.event_ended_time = convert_time(self.event_ended)
    self.event_duration = (self.event_ended_time -
                            self.event_began_time)*24
    self.year = find_year(self.event_began)
    self.city = find_city(self.city_county)
    self.county = find_county(self.city_county)
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
      logger.error("#{str} has not been parsed.")
      Time.now
    end
  end

  def find_year(str)
    convert_time(str).year
  end
end
