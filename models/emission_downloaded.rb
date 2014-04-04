class EmissionDownloaded
  include Mongoid::Document
  include Mongoid::Timestamps

  field :tracking_number, type: Integer
  field :status, type: String
  field :attempts, type: Integer, default: 0
  field :desc, type: String
  field :content, type: String

  validate :has_valid_status

  VALID_STATUSES = %w(done not_found failed)

  def self.tracking_number(filename)
    filename.split('/')[-1].split(".")[0]
  end

  def self.sync_db
    Dir["#{TMP_DIR}/*.html"].each do |filename|
      html = File.open(filename).read
      self.store(tracking_number(filename), "done", html.size, html)
    end
    "#{self.count} files stored"
  end

  def self.store(tn, status, desc="", content="")
    emission_downloaded = self.where(tracking_number: tn).first
    if emission_downloaded
      emission_downloaded.status = status
      emission_downloaded.attempts = emission_downloaded.attempts + 1
      emission_downloaded.desc = desc
      emission_downloaded.content = content
      emission_downloaded.save
    else
      emission_downloaded = self.create tracking_number: tn,
                                        status: status,
                                        attempts: 1,
                                        desc: desc,
                                        content: content
    end
    emission_downloaded
  end

  def self.downloaded?(tn)
    emission_downloaded = self.where(tracking_number: tn).first
    !!(emission_downloaded && emission_downloaded.status == "done")
  end

  def self.stats
    {
      downloaded: self.where(status: "done").count,
      not_found:  self.where(status: "not_found").count,
      failures:   self.where(status: "failed").count
    }
  end

  def has_valid_status
    VALID_STATUSES.include?(self.status)
  end
end
