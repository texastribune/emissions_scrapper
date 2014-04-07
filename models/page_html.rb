class PageHTML
  include Mongoid::Document
  include Mongoid::Timestamps

  field :status, type: String
  field :content, type: String
end