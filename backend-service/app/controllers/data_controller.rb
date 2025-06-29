class DataController < ApplicationController
  def index
    render json: { message: "This is protected data", time: Time.now }
  end
end
