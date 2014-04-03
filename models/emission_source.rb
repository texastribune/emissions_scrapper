class EmissionSource
  include Mongoid::Document
  field :name, type: String
  field :contaminant, type: Array
  field :authorization, type: Array
  field :limit, type: Array
  field :amount_released, type: Array
  field :limit_lbs, type: Array
  field :amount_released_lbs, type: Array

  belongs_to :emission_event

  def self.store(extracted_event, emission_event)
    emission_sources = extracted_event[:sources].map do |source|
      emission_source = self.new
      source.each do |key, value|
        emission_source.write_attribute(key, value)
      end
      if source.has_key?(:source_table)
        emission_source.write_attribute(:limit_lbs,
          source[:source_table][:limit].map(&:to_f))
        emission_source.write_attribute(:amount_released_lbs,
          source[:source_table][:amount_released].map(&:to_f))
      end
      emission_source.emission_event = emission_event
      emission_source
    end
    emission_sources.each(&:save)
  end
end
