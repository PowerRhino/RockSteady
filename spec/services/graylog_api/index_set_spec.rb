require 'rails_helper'

RSpec.describe GraylogApi::IndexSet do
  subject(:index_set_instance) { described_class.new(index_set, client) }

  let(:client) { instance_double(GraylogApi::Client) }

  before { allow(client).to receive(:get).and_return(response) }

  describe '#get' do
    context 'when the index_set is available' do
      let(:index_set) { 'requested_index_set' }
      let(:response) { response_stub(true) }

      it 'returns the id' do
        expect(index_set_instance.get).to eq 'requested_id'
      end
    end

    context 'when the index_set is not available' do
      let(:index_set) { 'not_available' }
      let(:response) { response_stub(true) }

      it 'returns the default' do
        expect(index_set_instance.get).to eq 'default_set_id'
      end
    end

    context 'when the response is not successful' do
      let(:index_set) { 'not_available' }
      let(:response) { response_stub(false) }

      it 'return nil' do
        expect(index_set_instance.get).to be_nil
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
