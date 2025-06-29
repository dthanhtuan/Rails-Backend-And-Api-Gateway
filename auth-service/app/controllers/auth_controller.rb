class AuthController < ApplicationController
  # NOTE: private key should be securely stored and not hardcoded in production
  PRIVATE_KEY = OpenSSL::PKey::RSA.new(File.read(Rails.root.join("config", "jwt_private.pem")))

  def login
    username = params[:username] || "guest"
    payload = { sub: username, exp: 1.hour.from_now.to_i }
    token = JWT.encode(payload, PRIVATE_KEY, "RS256")
    render json: { token: token }
  end
end
