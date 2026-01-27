
require 'action_dispatch/testing/integration'

class FetchView < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def run_script
    host! "127.0.0.1"
    user = User.where(email: 'fetchview@example.com').first_or_create!(password: 'password', password_confirmation: 'password')
    car = user.cars.first || user.cars.create!(make: 'Toyota', model: 'Camry', year: 2020)
    job = car.maintenance_jobs.create!(date: Date.today, mileage: 123, description: 'Test', price: 100)
    # create a part
    if job.parts.empty?
      job.parts.create!(name: 'Existing Part', price: 10)
    end

    sign_in user, scope: :user
    
    get edit_car_maintenance_job_path(car, job)
    
    puts response.body
  end
end

FetchView.new(nil).run_script
