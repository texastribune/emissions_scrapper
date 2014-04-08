class PageHTML
  include Mongoid::Document
  include Mongoid::Timestamps

  field :status, type: String
  field :content, type: String
  field :scrapped, type: Boolean, default: false
  field :tracking_number, type: String

  scope :done, where(status: 'done')
  scope :non_scrapped, where(scrapped: false)

  def self.not_downloaded_batch(list)
    list - self.in(tracking_number: list.map(&:to_s)).map(&:tracking_number)
  end
end
