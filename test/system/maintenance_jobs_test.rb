require "application_system_test_case"

class MaintenanceJobsTest < ApplicationSystemTestCase
  setup do
    @user = User.create!(email: "test@example.com", password: "password", password_confirmation: "password")
    @car = @user.cars.create!(make: "Toyota", model: "Camry", year: 2020)
  end

  test "adding a maintenance job with dynamic parts" do
    visit new_user_session_path
    fill_in "Email", with: @user.email
    fill_in "Password", with: "password"
    click_on "Log in"

    visit car_path(@car)
    click_on "Add Maintenance Job"

    fill_in "Description", with: "Comprehensive Service"
    fill_in "Mileage", with: 50000

    # Fill in the first part (already present)
    within all(".nested-fields")[0] do
      fill_in "Part Name", with: "Oil Filter"
      # Price field might be localized or just simple number. 
      # Assuming 'Price' label matches.
      fill_in "Price", with: "15.00"
    end

    # Add a second part
    click_on "Add Part"
    
    # Wait for new field by checking count or specific element
    assert_selector ".nested-fields", count: 2
    
    within all(".nested-fields")[1] do
      fill_in "Part Name", with: "Engine Oil"
      fill_in "Price", with: "45.00"
    end

    click_on "Create Maintenance job"

    assert_text "Maintenance job was successfully created"
    assert_text "Oil Filter"
    assert_text "Engine Oil"
    
    # Check total calculation on show page
    assert_text "$60.00" 
  end

  test "removing a part" do
    visit new_user_session_path
    fill_in "Email", with: @user.email
    fill_in "Password", with: "password"
    click_on "Log in"

    visit car_path(@car)
    click_on "Add Maintenance Job"

    # Add a part then remove it
    click_on "Add Part"
    assert_selector ".nested-fields", count: 2

    within all(".nested-fields")[1] do
      fill_in "Part Name", with: "Mistake Part"
      click_on "Remove"
    end
    
    # Stimulus controller hides it, doesn't remove from DOM immediately if persisted, 
    # but here it's new, so it might return true for newRecord.
    # In my controller: 
    # if (wrapper.dataset.newRecord === "true") { wrapper.remove() }
    # So it should be removed from DOM.
    assert_selector ".nested-fields", count: 1

    fill_in "Description", with: "Service with removed part"
    fill_in "Mileage", with: 50000
    
    within all(".nested-fields")[0] do
      fill_in "Part Name", with: "Real Part"
      fill_in "Price", with: "10.00"
    end

    click_on "Create Maintenance job"

    assert_text "Maintenance job was successfully created"
    assert_text "Real Part"
    refute_text "Mistake Part"
  end
end
