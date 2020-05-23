class GraylogValidator < ActiveModel::Validator
  def validate(record)
    return true unless ENV['GRAYLOG_ENABLED'].present?

    record.errors.add(:base, 'Could not create Graylog stream') unless record.graylog_stream.present?
  end
end
