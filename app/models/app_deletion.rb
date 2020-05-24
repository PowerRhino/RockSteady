class AppDeletion
  attr_reader :app
  private :app

  def initialize(app)
    @app = app
  end

  def delete!
    delete_graylog_stream if ENV['GRAYLOG_ENABLED'].present?

    HTTP.delete(url).status.success?
  end

  private

  def url
    ENV.fetch('NOMAD_API_URI') + '/v1/job/' + app.name
  end

  def delete_graylog_stream
    GraylogApi::Manager.new(app).delete_stream
  end
end
