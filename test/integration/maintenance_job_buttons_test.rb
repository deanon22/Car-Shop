require "test_helper"

class MaintenanceJobButtonsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.create!(email: "buttons_updated@example.com", password: "password", password_confirmation: "password")
    @car = @user.cars.create!(make: "Toyota", model: "Corolla", year: 2021)
    @maintenance_job = @car.maintenance_jobs.create!(date: Date.today, mileage: 10000, description: "Oil Change", price: 50.0)
    sign_in @user, scope: :user
  end

  test "maintenance jobs list has styled buttons and confirmation" do
    get car_path(@car)
    assert_response :success

    # Check for Show button styling
    assert_select "a[href=?]", car_maintenance_job_path(@car, @maintenance_job) do |elements|
      show_link = elements.find { |el| el.text == 'Show' }
      assert show_link, "Show link not found"
      assert_match /bg-blue-500/, show_link['class']
    end

    # Check for Edit button styling
    assert_select "a[href=?]", edit_car_maintenance_job_path(@car, @maintenance_job) do |elements|
      edit_link = elements.find { |el| el.text == 'Edit' }
      assert edit_link, "Edit link not found"
      assert_match /bg-yellow-500/, edit_link['class']
    end

    # Check for Destroy button (button content) inside a form
    assert_select "form[action=?][method='post']", car_maintenance_job_path(@car, @maintenance_job) do
      assert_select "input[name='_method'][value='delete']"
      
      # Check for Turbo confirm on the form itself (where data-turbo-confirm lives for button_to in Rails 7+)
      # Or standard data-turbo-confirm on the button depending on implementation.
      # Helper `button_to` puts `form: { data: ... }` attributes on the form tag.
      assert_select "[data-turbo-confirm='Are you sure you want to delete this Maintenance Job?']"
      
      assert_select "button[type='submit']", text: "Destroy" do |btn|
        assert_match /bg-red-500/, btn.first['class']
      end
    end
  end
end
