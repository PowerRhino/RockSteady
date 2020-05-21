class CreateGraylogStreams < ActiveRecord::Migration[5.1]
  def change
    create_table :graylog_streams do |t|
      t.string :stream_id
      t.string :stream_name
      t.string :stream_rule_value
      t.string :index_set
      t.belongs_to :app, foreign_key: true

      t.timestamps
    end
  end
end
