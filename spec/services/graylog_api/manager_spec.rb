require 'rails_helper'

RSpec.describe GraylogApi::Manager do
  subject(:manager) { described_class.new(app, params) }
  let(:params) {
    {
      'name'=> 'efi-local-test-000',
      'description' => 'test',
      'image_source'=>'ecr',
      'add_graylog_stream'=>'1',
      'repository_name' => 'my-repo'
    }
  }

  let(:app) { instance_double('App', { repository_name: 'test', name: 'app name'}) }

  describe '#setup' do
    let(:index_sets) {
      {
        index_sets: [
          {'id' => '123', 'index_prefix' => 'graylog'}
        ]
      }
    }
    let(:headers) { {'Content-Type' => 'application/json'} }
    let(:stream) { {stream_id: '999'} }
    let(:role) {
      {
        name: 'Dev',
        description: 'Altmetric developers',
        permissions: [
          'streams:read:777'
        ]
      }
    }

    context 'when all the requests are successful' do
      before do
        stub_request(:get, 'https://test.com/api/system/indices/index_sets')
          .to_return(status: 200, body: index_sets.to_json, headers: headers)

        stub_request(:post, "https://test.com/api/streams")
          .to_return(status: 200, body: stream.to_json, headers: headers)

        stub_request(:post, 'https://test.com/api/streams/999/resume')
          .to_return(status: 200, body: ''.to_json, headers: headers)

        stub_request(:get, 'https://test.com/api/roles/Dev')
          .to_return(status: 200, body: role.to_json, headers: headers )

        stub_request(:put, 'https://test.com/api/roles/Dev')
          .to_return(status: 200, body: '', headers: {})
      end

      it 'returns a hash with the result and a stream_id' do
        expect(manager.setup[:result]).to be_success
      end
    end

    context 'when the stream is not created successfully cause of a bad response' do
        before do
          stub_request(:get, 'https://test.com/api/system/indices/index_sets')
            .to_return(status: 400)
          stub_request(:post, 'https://test.com/api/streams')
            .to_return(status: 400)
        end

      it 'returns a failure response' do
        expect(manager.setup[:result]).to_not be_success
      end
    end

    context 'when the stream is not created successfully cause of a network error' do
      before do
        stub_request(:get, 'https://test.com/api/system/indices/index_sets')
          .to_return(status: 200, body: index_sets.to_json, headers: headers)
        stub_request(:post, 'https://test.com/api/streams')
          .to_raise(HTTP::Error)
      end

      it 'returns a failure response' do
        expect(manager.setup[:result]).to_not be_success
      end
    end
  end

  describe '#delete_stream' do
    let(:stream) { GraylogStream.new(stream_id: '123') }
    let(:app) { App.create(name: 'app name', repository_name: 'test', job_spec: '{}', graylog_stream: stream) }

    context 'when the request is successful' do
      before do
        stub_request(:delete, 'https://test.com/api/streams/123')
          .to_return(status: 200, body: '', headers: {})
      end

      it 'removes the stream from the index and returns a result object' do
        expect(described_class.new(app).delete_stream).to be_success
      end
    end

    context 'when the request is not successful' do
      before do
        stub_request(:delete, 'https://test.com/api/streams/123')
          .to_return(status: 400, body: '', headers: {})
      end

      it 'removes the stream from the index and returns a result object' do
        expect(described_class.new(app).delete_stream).to_not be_success
      end
    end
  end

  def response_stub(successful)
    OpenStruct.new(
      success?: successful,
      body: {
        index_sets: [
          {
            'index_prefix' => 'requested_index_set',
            'id'  => 'requested_id'
          },
          {
            'index_prefix' => 'graylog',
            'id'  => 'default_set_id'
          }
        ]
      }
    )
  end
end
