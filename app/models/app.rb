class App < ApplicationRecord
  has_one :graylog_stream, dependent: :destroy

  NAME_FORMAT = /\A[a-z0-9\-]+\Z/.freeze
  GREYLOG_PARAMS = %i[
    add_graylog_stream
  ].freeze

  validates :name, uniqueness: true, presence: true, format: { with: NAME_FORMAT }
  validates :image_source, inclusion: { in: %w[dockerhub ecr] }
  validates :repository_name, presence: true
  validates :job_spec, presence: true
  validates_with GraylogValidator

  def self.build(params)
    App.new(params.except(*GREYLOG_PARAMS)).build_graylog(params)
  end

  def to_param
    name
  end

  def trigger_auto_deploy(notification)
    return unless auto_deploy? &&
      auto_deploy_branch == notification.branch &&
      notification.finished? &&
      notification.success?

    AppDeployment.new(self, "build-#{notification.build_number}").deploy!
  end

  def build_graylog(params)
    if add_to_graylog?(params)
      stream_info = GraylogApi::Manager.new(self, params).setup

      return build_associated_stream(stream_info) if stream_info[:result].success?
    end

    self
  end

  private

  def build_associated_stream(stream_info)
    build_graylog_stream
    graylog_stream.stream_name = name
    graylog_stream.stream_rule_value = name
    graylog_stream.index_set = repository_name
    graylog_stream.stream_id = stream_info[:stream_id]

    self
  end

  def add_to_graylog?(params)
    params[GREYLOG_PARAMS.first] == '1'
  end
end
