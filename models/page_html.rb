class PageHTML
  include Mongoid::Document
  include Mongoid::Timestamps

  field :status, type: String
  field :content, type: String
  field :tracking_number, type: Integer

  def self.not_downloaded_batch(list)
    self.in(tracking_number: list.map(&:to_s)).map(&:tracking_number)
  end
end
