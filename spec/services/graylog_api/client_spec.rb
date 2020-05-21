require 'rails_helper'

RSpec.describe GraylogApi::Client do
  subject(:client) { described_class.new }

  before { ENV['GRAYLOG_ENABLED'] = 'true' }
  after { ENV.delete('GRAYLOG_ENABLED') }

  describe '#get' do
    context 'when successful' do
      before { stub_api_request(:get) }

      it 'returns a succesful response' do
        expect(client.get('/streams')).to be_success
      end
    end

    context 'when not successful' do
      before { stub_api_request_error(:get) }

      it 'returns a failure response' do
        expect(client.get('/streams')).to_not be_success
      end
    end
  end

  describe '#post' do
    context 'when successful' do
      let(:payload) { {'stream' => 'test'} }

      before { stub_api_request(:post) }

      it 'returns a succesful response' do
        expect(client.post('/streams', payload)).to be_success
      end
    end

    context 'when not successful' do
      let(:payload) { {'stream' => 'test'} }

      before { stub_api_request_error(:post) }

      it 'returns a failure response' do
        expect(client.post('/streams', payload)).to_not be_success
      end
    end
  end

  describe '#put' do
    context 'when successful' do
      let(:payload) { {'stream' => 'test'} }

      before { stub_api_request(:put) }

      it 'returns a succesful response' do
        expect(client.put('/streams', payload)).to be_success
      end
    end

    context 'when not successful' do
      let(:payload) { {'stream' => 'test'} }

      before { stub_api_request_error(:put) }

      it 'returns a failure response' do
        expect(client.put('/streams', payload)).to_not be_success
      end
    end
  end

  def stub_api_request(method)
    stub_request(method, 'https://test.com/api/streams')
      .with(
        headers: {
          'Accept' => 'application/json',
          'Authorization' => 'Basic dGVzdC1ib3Q6cGFzc3dvcmQ=',
          'Connection' => 'close',
          'Host' => 'test.com',
          'User-Agent' => 'http.rb/4.1.1',
          'X-Requested-By' => 'Graylog API bot'
        }
      )
      .to_return(status: 200, body: '', headers: {})
  end

  def stub_api_request_error(method)
    stub_request(method, 'https://test.com/api/streams')
      .with(
        headers: {
          'Accept' => 'application/json',
          'Authorization' => 'Basic dGVzdC1ib3Q6cGFzc3dvcmQ=',
          'Connection' => 'close',
          'Host' => 'test.com',
          'User-Agent' => 'http.rb/4.1.1',
          'X-Requested-By' => 'Graylog API bot'
        }
      )
      .to_raise(HTTP::Error)
  end
end
