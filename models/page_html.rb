class PageHTML < Sequel::Model
  def self.not_downloaded_batch(tracking_numbers)
    existing = dataset.where(tracking_number: tracking_numbers).
                        select(:tracking_number).map(&:tracking_number)
    tracking_numbers - existing
  end

  def self.insert(downloaded_pages)
    self.dataset.multi_insert(downloaded_pages)
  end

  def self.non_scrapped_count
    dataset.where(scrapped: false).count
  end

  def self.non_scrapped_paginate(page, per_page=100)
    dataset.where(scrapped: false).
            limit(per_page.to_i).
            offset(((page-1)*per_page).to_i)
  end

  def scrapped!
    update_fields({scrapped: true}, [:scrapped])
  end
end
