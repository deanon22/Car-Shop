require "test_helper"

class DynamicPartsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @user = User.create!(email: "integration@example.com", password: "password", password_confirmation: "password")
    @car = @user.cars.create!(make: "Toyota", model: "Corolla", year: 2021)
    sign_in @user, scope: :user
  end

  test "maintenance job form has dynamic parts attributes" do
    get new_car_maintenance_job_path(@car)
    assert_response :success

    # Verify Stimulus controller connection
    assert_select "div[data-controller='nested-form']"
    assert_select "div[data-nested-form-target='container']"
    
    # Verify Add Part button
    assert_select "button[data-action='nested-form#add']", text: "Add Part"

    # Verify Template
    assert_select "template[data-nested-form-target='template']" do
      assert_select "div.nested-fields" do
        assert_select "button[data-action='nested-form#remove']", text: "Remove"
      end
    end

    # Verify initial part field (should have 1)
    assert_select "#parts .nested-fields", count: 1
  end
end
