module GraylogApi
  class Role
    ENDPOINT = '/roles'.freeze

    attr_reader :role, :client
    private :role, :client

    def initialize(name, client)
      @role = { name: name }
      @client = client
    end

    def read
      response = client.get("#{ENDPOINT}/#{role[:name]}")
      @role = response.body if response.success?
      response
    end

    def update(stream_id)
      result = read
      return result unless result.success?

      update_permissions(stream_id)
      client.put("#{ENDPOINT}/#{role[:name]}", role)
    end

    private

    def update_permissions(stream_id)
      @role[:permissions] = role[:permissions] << permissions_read_syntax(stream_id)
    end

    def permissions_read_syntax(stream_id)
      "streams:read:#{stream_id}"
    end
  end
end
