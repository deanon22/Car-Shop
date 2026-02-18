class HomeController < ApplicationController
  def index
    if user_signed_in?
      @cars = current_user.cars
      @jobs = MaintenanceJob.where(car: @cars)
      @recent_jobs = @jobs.order(created_at: :desc).limit(5)
      
      # Simple metrics
      @total_cars = @cars.count
      @total_jobs = @jobs.count
      
      # Calculate total spent (naive approach for now)
      @total_spent = @jobs.sum(:price) + Part.where(maintenance_job: @jobs).sum(:price)
    else
      redirect_to new_user_session_path
    end
  end
end
