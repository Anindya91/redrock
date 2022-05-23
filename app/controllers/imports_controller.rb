class ImportsController < ApplicationController
  http_basic_authenticate_with(
    name: Rails.application.credentials.admin_username,
    password: Rails.application.credentials.admin_password,
    only: :index
  )
  skip_before_action :verify_authenticity_token

  def index
  end

  def create
    render json: { ip: request.remote_ip }
  end
end
