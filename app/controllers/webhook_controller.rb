class WebhookController < ActionController::API
  def deploy
    autodeployed_apps = apps.select { |app| app.trigger_auto_deploy(notification) }

    if autodeployed_apps.any?
      head 200
    else
      head 204
    end
  end

  def deploy_app
    if app.trigger_auto_deploy(notification)
      head 200
    else
      head 204
    end
  end

  private

  def apps
    @apps ||= App.where(repository_name: notification.repository_name)
  end

  def app
    @app ||= App.find_by(name: params[:app])
  end

  def notification
    @notification ||= CircleBuildNotification.new(params[:payload])
  end
end
