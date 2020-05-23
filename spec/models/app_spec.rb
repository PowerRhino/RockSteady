require 'rails_helper'

RSpec.describe App do
  def app_named(name, options = {})
    App.create(
      { name: name, repository_name: 'test', job_spec: 'job {}' }.merge(options)
    )
  end

  def notification_for(branch)
    CircleBuildNotification.new(
      outcome: 'success',
      lifecycle: 'finished',
      build_num: '27',
      branch: branch,
      repository_name: 'foo-bar'
    )
  end

  describe 'name' do
    it 'cannot contain spaces' do
      expect(app_named('test app').errors.messages[:name]).to include('is invalid')
    end

    it 'cannot contain uppercase characters' do
      expect(app_named('Testapp').errors.messages[:name]).to include('is invalid')
    end

    it 'cannot contain symbols' do
      expect(app_named('te$tapp').errors.messages[:name]).to include('is invalid')
    end

    it 'can contain lowercase characters, digits, and hyphens' do
      expect(app_named('test-app').errors.messages[:name]).to be_empty
    end

    it 'is unique' do
      app_named('test-app')

      expect(app_named('test-app').errors.messages[:name]).to include('has already been taken')
    end
  end

  describe '#trigger_auto_deploy' do
    it 'returns nil if app is autodeploy disabled' do
      notification = notification_for('master')

      expect(app_named('no-auto-deploy').trigger_auto_deploy(notification)).to be_nil
    end

    it 'returns nil if app auto deploy branch does not match notification branch' do
      notification = notification_for('staging')

      expect(
        app_named('no-auto-deploy', auto_deploy_branch: 'master', auto_deploy: true).trigger_auto_deploy(notification)
      ).to be_nil
    end

    it 'creates a job in nomad if an app is deployable' do
      notification = notification_for('master')

      request = stub_request(:post, /jobs/).to_return(status: 200, body: '{"TaskGroups":[]}', headers: { 'Content-Type' => 'application/json' })
      app_named('no-auto-deploy', auto_deploy_branch: 'master', auto_deploy: true).trigger_auto_deploy(notification)
      expect(request).to have_been_made.at_least_once
    end

    it 'raises an error if job creation fails' do
      notification = notification_for('master')

      stub_request(:post, /jobs/).to_timeout
      expect { app_named('no-auto-deploy', auto_deploy_branch: 'master', auto_deploy: true).trigger_auto_deploy(notification) }.to raise_error(HTTP::TimeoutError)
    end
  end

  describe '#build_graylog' do
    def app_initialised(name, options = {})
      App.new(
        { name: name, repository_name: 'test', job_spec: 'job {}' }.merge(options)
      )
    end

    let(:params) { {} }
    let(:api_manager) { class_double(GraylogApi::Manager) }

    before do
      ENV['GRAYLOG_ENABLED'] == 'true'
      allow(api_manager).to receive(:new)
    end

    context 'when an app is invalid' do
      it 'does nothing' do
        app_initialised('invalid name').build_graylog(params)

        expect(api_manager).to_not have_received(:new)
      end
    end

    context 'when an app is valid but add_graylog_stream param is missing' do
      it 'does nothing' do
        app_initialised('valid').build_graylog(params)

        expect(api_manager).to_not have_received(:new)
      end
    end

    context 'when an app is valid but add_graylog_stream param is not ticked' do
      let(:params) { { add_graylog_stream: '0' } }

      it 'does nothing' do
        app_initialised('valid').build_graylog(params)

        expect(api_manager).to_not have_received(:new)
      end
    end

    context 'when an app is valid and add_graylog_stream is ticked' do
      let(:params) { { add_graylog_stream: '1' } }
      let(:result_stub) {
        {
          result: OpenStruct.new(success?: true )
        }
      }

      it 'initialises the setup process and builds the association' do
        api_manager_instance = instance_double(GraylogApi::Manager)

        allow(GraylogApi::Manager).to receive(:new).and_return(api_manager_instance)
        allow(api_manager_instance).to receive(:setup).and_return(result_stub)
        app = app_initialised('name').build_graylog(params)

        expect(app.graylog_stream).to_not be_nil
      end
    end

    context 'when the result is not successful' do
      let(:params) { { add_graylog_stream: '1' } }
      let(:result_stub) {
        {
          result: OpenStruct.new(success?: false, message: 'Cannot create graylog stream' )
        }
      }

      it 'the associated graylog_stream is not built' do
        api_manager_instance = instance_double(GraylogApi::Manager)

        allow(GraylogApi::Manager).to receive(:new).and_return(api_manager_instance)
        allow(api_manager_instance).to receive(:setup).and_return(result_stub)
        app = app_initialised('name').build_graylog(params)

        expect(app.graylog_stream).to be_nil
      end
    end
  end
end
