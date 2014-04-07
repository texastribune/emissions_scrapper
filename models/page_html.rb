class PageHTML
  include Mongoid::Document
  include Mongoid::Timestamps

  field :status, type: String
  field :content, type: String
  field :tracking_number, type: String

  def self.not_downloaded_batch(list)
    list - self.in(tracking_number: list.map(&:to_s)).map(&:tracking_number)
  end
end
