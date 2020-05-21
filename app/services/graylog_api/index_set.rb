module GraylogApi
  class IndexSet
    ENDPOINT = '/system/indices/index_sets'.freeze
    DEFAULT_INDEX_PREFIX = 'graylog'.freeze

    attr_reader :client, :index_set
    private :client, :index_set

    def initialize(index_set, client)
      @client = client
      @index_set = index_set
    end

    def get
      response = client.get(ENDPOINT)

      return unless response.success?

      set = preferred_set(response)

      return set_id(set) if set.present?

      set_id(default_set(response))
    end

    private

    def set_id(index_set)
      index_set&.fetch('id')
    end

    def preferred_set(response)
      response.body[:index_sets].find { |set| set['index_prefix'] == index_set }
    end

    def default_set(response)
      response.body[:index_sets].find { |set| set['index_prefix'] == DEFAULT_INDEX_PREFIX }
    end
  end
end
