module GraylogApi
  class Stream
    ENDPOINT = '/streams'.freeze
    START_PATH = '/resume'.freeze
    MATCH_EXACTLY = 1

    attr_reader :id, :stream, :client, :index_set_id
    private :stream, :client

    def initialize(title, index_set_id, client)
      @stream = {
        title: title,
        description: "Logs for #{title}",
        rules: [{ type: MATCH_EXACTLY, value: title, field: 'tag', inverted: false }],
        content_pack: nil,
        matching_type: 'AND',
        remove_matches_from_default_stream: true,
        index_set_id: index_set_id
      }
      @client = client
      @index_set_id = index_set_id
    end

    def create
      response = client.post(ENDPOINT, stream)
      @id = response.body[:stream_id] if response.success?
      response
    end

    def start
      client.post("#{ENDPOINT}/#{id}#{START_PATH}", nil)
    end
  end
end
