require 'rails_helper'

RSpec.describe "Homes", type: :request do
  describe "GET /index" do
    it 'response successfully' do
      get '/'
      expect(response).to have_http_status 200
    end
  end
end