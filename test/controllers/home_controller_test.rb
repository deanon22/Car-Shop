require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email: "test_#{Time.now.to_i}@example.com", password: "password")
  end

  test "should get index" do
    sign_in @user, scope: :user
    get home_index_url
    assert_response :success
  end
end
