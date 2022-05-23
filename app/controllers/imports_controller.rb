class ImportsController < ApplicationController
  http_basic_authenticate_with(
    name: Rails.application.credentials.admin_username,
    password: Rails.application.credentials.admin_password,
    only: :index
  )

  def index
  end
end
