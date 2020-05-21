require 'rails_helper'

RSpec.describe GraylogApi::Role do
  subject(:role) { described_class.new(name, client) }

  let(:name) { {name: 'a name' } }
  let(:client) { instance_double(GraylogApi::Client) }

  before { allow(client).to receive(:get).and_return(response) }

  describe '#read' do
    context 'when the role is retrieved successfully' do
      let(:response) { response_stub(true) }

      it 'returns a successful response' do
        expect(role.read).to be_success
      end
    end

    context 'when the role cannot be retrieved' do
      let(:response) { response_stub(false) }

      it 'returns a failure response' do
        expect(role.read).to_not be_success
      end
    end
  end

  describe '#update' do
    let(:stream_id) { '1dc635244cedfd1112d49783' }

    context 'when the role can be updated' do
      let(:response) { response_stub(true) }

      it 'returns a successful response' do
        allow(client).to receive(:put).and_return(response)

        expect(role.update(stream_id)).to be_success
      end
    end

    context 'when the role cannot be updated' do
      let(:response) { response_stub(false) }

      it 'returns a failure response' do
        expect(role.update(stream_id)).to_not be_success
      end
    end
  end

  def response_stub(successful)
    OpenStruct.new(
      success?: successful,
      body: {
        name: 'Dev',
        description: 'Altmetric developers',
        permissions: [
          'streams:read:3x1234d74cedfd001230e45g'
        ]
      }
    )
  end
end
