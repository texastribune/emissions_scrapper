class Page
  include ElasticsearchStorer

  def self.downloaded?(id)
    page = begin
      self.class.find(id)
    rescue Stretcher::RequestError::NotFound
      nil
    end
    page && page.status == "done"
  end
end

__END__

total = EmissionDownloaded.count
per_page = 500
total_pages = (total / 100.0).ceil
total_pages.times.each do |page|
  emissions = EmissionDownloaded.limit(per_page).skip(page * per_page)
  data = emissions.map do |emission|
    tmp = emission.attributes
    tmp["_id"] = emission.attributes['tracking_number']
    tmp
  end

  Page.bulk(data)
end

102359