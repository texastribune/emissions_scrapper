class PageHTML < Sequel::Model
  def self.not_downloaded_batch(tracking_numbers)
    existing = dataset.where(tracking_number: tracking_numbers).
                        select(:tracking_number).map(&:tracking_number)
    tracking_numbers - existing
  end

  def self.insert(page_data)
    begin
      self.dataset.insert(page_data)
    rescue Sequel::DatabaseError => e
      logger.error("#{page_data[:tracking_number]} failed with #{e.message}")
    end
  end

  def self.non_scrapped_count
    dataset.where(scrapped: false).count
  end

  def self.non_scrapped_paginate(page, per_page=100)
    dataset.where(scrapped: false).
            limit(per_page.to_i).
            offset(((page-1)*per_page).to_i)
  end

  def self.last
    begin
      order(Sequel.desc(:tracking_number)).limit(1).first.tracking_number
    rescue NoMethodError
      0
    end
  end

  def scrapped!
    update_fields({scrapped: true}, [:scrapped])
  end
end
