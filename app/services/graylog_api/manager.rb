module GraylogApi
  class Manager
    ROLE = 'Dev'.freeze

    attr_reader :app, :params
    private :app, :params

    def initialize(app, params = {})
      @app = app
      @params = params
    end

    def setup
      stream = Stream.new(app.name, index_set_id, client)
      result = stream.create
      return { result: result } unless result.success?

      stream.start
      role.update(stream.id)

      {
        result: result,
        stream_id: stream.id
      }
    end

    def delete_stream
      client.delete(Stream::ENDPOINT, app.graylog_stream.stream_id)
    end

    def index_set_id
      @index_set ||= IndexSet.new(index_set, client).get
    end

    def role
      @role ||= Role.new(ROLE, client)
    end

    def client
      @client ||= Client.new
    end

    private

    def index_set
      app.repository_name
    end
  end
end
