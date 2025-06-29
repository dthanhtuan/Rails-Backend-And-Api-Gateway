class DataController < ApplicationController
  before_action :verify_gateway_header

  def index
    render json: { message: "This is protected data", time: Time.now }
  end

  private

  def verify_gateway_header
    expected_token = "my-secret-token-123" # NOTE: Must match the token set in Express Gateway
    received_token = request.headers["x-gateway-auth"]

    unless received_token.present? && ActiveSupport::SecurityUtils.secure_compare(received_token, expected_token)
      render json: { error: "Forbidden: invalid gateway token" }, status: :forbidden
    end
  end
end
