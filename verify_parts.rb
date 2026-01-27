
user = User.first || User.create!(email: 'test@example.com', password: 'password', password_confirmation: 'password')
car = user.cars.first || user.cars.create!(make: 'Toyota', model: 'Camry', year: 2020)

# Test creation WITHOUT receipt (should succeed)
job = car.maintenance_jobs.create!(
  date: Time.current,
  mileage: 12000,
  description: 'Brake check',
  price: 0.0,
  parts_attributes: [
    { name: 'Brake Pads', price: 50.0 }
  ]
)

if job.persisted? && !job.receipt.attached?
  puts "SUCCESS: Job created without receipt."
else
  puts "FAILURE: Job failed to create without receipt: #{job.errors.full_messages}"
end

# Test creation WITH receipt (should succeed)
require 'open-uri'
# Create a dummy file for testing
File.write('test_receipt.txt', 'Receipt content')

job2 = car.maintenance_jobs.new(
  date: Time.current,
  mileage: 13000,
  description: 'Battery replacement',
  price: 10.0,
  parts_attributes: [
    { name: 'Battery', price: 100.0 }
  ]
)
job2.receipt.attach(io: File.open('test_receipt.txt'), filename: 'test_receipt.txt', content_type: 'text/plain')
job2.save!

if job2.persisted? && job2.receipt.attached?
  puts "SUCCESS: Job created with receipt."
else
  puts "FAILURE: Job failed to create with receipt: #{job2.errors.full_messages}"
end

# Clean up
File.delete('test_receipt.txt') if File.exist?('test_receipt.txt')
