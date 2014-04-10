desc "Import files"
task import_files: :environment do
  Dir["/Users/malev/tmp/tmp/*.html"].each do |filename|
    tracking_number = File.basename(filename, ".html")
    html = File.open(filename).read

    table = DB[:page_htmls]
    table.insert(
      content: html.strip,
      tracking_number: tracking_number.to_i,
      status: 'done'
    )
  end
end

task import_db: :environment do
  table = DB[:page_htmls]
  total_documents = PageHTML.count
  per_page = 100.0
  total_pages = (total_documents/per_page).ceil
  pbar = ProgressBar.new("Importing", total_documents)
  total_pages.times.each do |page|
    PageHTML.limit(per_page).skip(page*per_page).each do |page|
      begin
        table.insert({
          content: page.content.strip,
          tracking_number: page.tracking_number,
          status: 'done'
        })
      rescue Sequel::UniqueConstraintViolation => e
        puts "#{page.tracking_number} already in the database"
      end
      pbar.inc
    end
  end
end

task migrate: :environment do
  unless DB.table_exists? :page_htmls
    DB.create_table :page_htmls do
      primary_key :id
      File        :content
      Integer     :tracking_number, unique: true
      String      :status
      Boolean     :scrapped, default: false
    end
  end

  unless DB.table_exists? :emission_events
    DB.create_table :emission_events do
      foreign_key :page_html_id, :page_htmls

      String :regulated_entity_name
      Text   :physical_location
      String :regulated_entity_rn_number
      String :city_county
      String :type_of_air_emission_event
      String :event_began
      String :event_ended
      String :this_is_based_on_the
      Text   :cause
      Text   :action_taken
      Text   :emissions_estimation_method
      Integer :tracking_number

      DateTime :event_began_time
      DateTime :event_ended_time
      Float :event_duration, default: 0
      String :city
      String :county
    end
  end
end
