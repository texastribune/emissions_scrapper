module ElasticsearchStorer
  module ClassMethods
    def type_name
      self.new.type_name
    end

    def index_name
      self.new.index_name
    end

    def server
      self.new.server
    end

    def bulk(list)
      bulkable = list.map { |element| element["_type"] = type_name; element }
      server.index(index_name).bulk_index(bulkable)
    end

    def find(id)
      server.index(index_name).type(type_name).get(id)
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end

  def server
    @server ||= Stretcher::Server.new(
      "http://#{config['hostname']}:#{config['port']}",
      logger: logger
    )
  end

  def save
    server.index(index_name).type(type_name).post(@attributes)
  end

  def index_name
    config['index_name']
  end

  def type_name
    self.class.to_s.downcase.pluralize
  end

  def config
    @config ||= YAML.load_file('config/elasticsearch.yml')[APP_ENV]
  end
end
