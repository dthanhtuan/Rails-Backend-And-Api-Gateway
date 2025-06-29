class AuthController < ApplicationController
  before_action :verify_gateway_header

  # NOTE: private key should be securely stored and not hardcoded in production
  PRIVATE_KEY = OpenSSL::PKey::RSA.new(File.read(Rails.root.join("config", "jwt_private.pem")))

  def login
    username = params[:username] || "guest"
    payload = { sub: username, exp: 1.hour.from_now.to_i }
    token = JWT.encode(payload, PRIVATE_KEY, "RS256")
    render json: { token: token }
  end

  private

  def verify_gateway_header
    expected_token = "my-secret-token-123" # Must match the gateway secret
    received_token = request.headers["x-gateway-auth"]

    unless received_token.present? && ActiveSupport::SecurityUtils.secure_compare(received_token, expected_token)
      render json: { error: "Forbidden: invalid gateway token" }, status: :forbidden
    end
  end
end
