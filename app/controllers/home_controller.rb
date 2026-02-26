class HomeController < ApplicationController
  def index
    if user_signed_in?
      @cars = current_user.cars
      @jobs = MaintenanceJob.where(car: @cars).includes(:car, :parts)
      
      @range = params[:range] || "this_month"
      
      case @range
      when "this_month"
        @filtered_jobs = @jobs.where(date: Time.current.all_month)
        @range_label = "This Month"
      when "last_3_months"
        @filtered_jobs = @jobs.where(date: 3.months.ago.beginning_of_day..Time.current.end_of_day)
        @range_label = "Last 3 Months"
      when "last_6_months"
        @filtered_jobs = @jobs.where(date: 6.months.ago.beginning_of_day..Time.current.end_of_day)
        @range_label = "Last 6 Months"
      when "last_year"
        @filtered_jobs = @jobs.where(date: 1.year.ago.beginning_of_day..Time.current.end_of_day)
        @range_label = "Last Year"
      when "all_time"
        @filtered_jobs = @jobs
        @range_label = "All Time"
      else
        @filtered_jobs = @jobs.where(date: Time.current.all_month)
        @range_label = "This Month"
      end

      @recent_jobs = @filtered_jobs.order(date: :desc).limit(5)
      
      # Simple metrics based on filter
      @total_jobs = @filtered_jobs.count
      @total_cars = @cars.count # Cars count usually stays total unless requested otherwise
      
      # Calculate total spent for filtered jobs
      job_ids = @filtered_jobs.select(:id)
      @total_spent = (@filtered_jobs.sum(:price) || 0) + (Part.where(maintenance_job_id: job_ids).sum(:price) || 0)

      respond_to do |format|
        format.html do
          # Calculate monthly spending for the last 12 months (this chart usually shows historical data regardless of filter, but let's keep it as is or maybe it should also be affected? The user said "corresponding maintenance jobs that fit into those date ranges", usually that applies to the stats and list. The chart is explicitly "for the last 12 months" in the comments.)
          @monthly_data = (0..11).map do |i|
            date = i.months.ago.beginning_of_month
            jobs_in_month = @jobs.where(date: date..date.end_of_month)
            base_sum = jobs_in_month.sum(:price) || 0
            parts_sum = Part.where(maintenance_job_id: jobs_in_month.select(:id)).sum(:price) || 0
            {
              month: date.strftime("%b"),
              total: base_sum + parts_sum
            }
          end.reverse
          
          @max_monthly = @monthly_data.map { |d| d[:total] }.max.to_f
          @max_monthly = 1.0 if @max_monthly == 0

          # Calculate spending by car for the donut chart
          @spending_by_car = @cars.map do |car|
            car_jobs = @filtered_jobs.where(car_id: car.id)
            base_sum = car_jobs.sum(:price) || 0
            parts_sum = Part.where(maintenance_job_id: car_jobs.select(:id)).sum(:price) || 0
            {
              name: "#{car.make} #{car.model}",
              total: base_sum + parts_sum
            }
          end.sort_by { |d| -d[:total] }
        end
        format.csv do
          send_data generate_csv(@filtered_jobs), filename: "maintenance_jobs_#{@range}_#{Date.today}.csv"
        end
      end
    else
      redirect_to new_user_session_path
    end
  end

  private

  def generate_csv(jobs)
    require 'csv'
    CSV.generate(headers: true) do |csv|
      csv << ["Date", "Car", "Description", "Base Price", "Parts Price", "Total Cost"]
      jobs.each do |job|
        parts_price = job.parts.sum(:price) || 0
        csv << [
          job.date,
          "#{job.car.year} #{job.car.make} #{job.car.model}",
          job.description,
          job.price,
          parts_price,
          job.total_cost
        ]
      end
    end
  end
end
