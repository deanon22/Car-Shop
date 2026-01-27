# Set up the environment
require 'action_view'
require 'action_controller'

# Mocking necessary parts to render the partial
class MockController < ActionController::Base
  helper Rails.application.helpers
  helper_method :protect_against_forgery?
  def protect_against_forgery?
    false
  end
end

# Find or create data
user = User.first || User.create!(email: 'debug_view@example.com', password: 'password', password_confirmation: 'password')
car = user.cars.first || user.cars.create!(make: 'Toyota', model: 'Camry', year: 2020)
job = car.maintenance_jobs.create!(
  date: Date.today, 
  mileage: 123, 
  description: 'Test Job', 
  price: 100,
  parts_attributes: [{ name: 'Part 1', price: 10 }]
)

# Render the form
view = ActionView::Base.with_empty_template_cache
view = view.with_view_paths([Rails.root.join('app', 'views')])
view.class_eval do
  include Rails.application.routes.url_helpers
  include ActionView::Helpers
  include ActionView::Helpers::FormHelper
  
  def default_url_options
    { host: 'localhost:3000' }
  end
  
  def protect_against_forgery?
    false
  end
end

renderer = ActionController::Base.renderer.new(http_host: 'example.org', https: false)
html = renderer.render(
  partial: 'maintenance_jobs/form',
  locals: { car: car, maintenance_job: job }
)

puts html
