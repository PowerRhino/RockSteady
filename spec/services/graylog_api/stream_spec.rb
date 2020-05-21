require 'rails_helper'

RSpec.describe GraylogApi::Stream do
  subject(:stream) { described_class.new(title, index_set_id, client) }

  let(:title) { 'a title' }
  let(:index_set_id) { '2cf6d1dd4abcfd87322378f2' }
  let(:client) { instance_double(GraylogApi::Client) }

  describe '#create' do
    before { allow(client).to receive(:post).and_return(response) }

    context 'when the stream is created' do
      let(:response) { response_stub(true) }

      it 'returns a successful response' do
        expect(stream.create).to be_success
      end
    end

    context 'when the stream is not created' do
      let(:response) { response_stub(false) }

      it 'returns a failure response' do
        expect(stream.create).to_not be_success
      end
    end
  end

  describe '#start' do
    before { allow(client).to receive(:post).and_return(response) }

    context 'when the stream can be started' do
      let(:response) { response_stub(true) }

      it 'returns a successful response' do
        expect(stream.start).to be_success
      end
    end

    context 'when the stream cannot be started' do
      let(:response) { response_stub(false) }

      it 'returns a successful response' do
        expect(stream.start).to_not be_success
      end
    end
  end

  def response_stub(successful)
    OpenStruct.new(
      success?: successful,
      body: {
        stream_id: 1
      }
    )
  end
end
