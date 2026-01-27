class MaintenanceJobsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_car
  before_action :set_maintenance_job, only: [:show, :edit, :update, :destroy]

  def show
  end

  def new
    @maintenance_job = @car.maintenance_jobs.build
    @maintenance_job.parts.build
  end

  def create
    @maintenance_job = @car.maintenance_jobs.build(maintenance_job_params)
    if @maintenance_job.save
      redirect_to car_path(@car), notice: 'Maintenance job was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @maintenance_job.update(maintenance_job_params)
      redirect_to car_maintenance_job_path(@car, @maintenance_job), notice: 'Maintenance job was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @maintenance_job.destroy
    redirect_to car_path(@car), notice: 'Maintenance job was successfully destroyed.'
  end

  private

  def set_car
    @car = current_user.cars.find(params[:car_id])
  end

  def set_maintenance_job
    @maintenance_job = @car.maintenance_jobs.find(params[:id])
  end

  def maintenance_job_params
    params.require(:maintenance_job).permit(:date, :mileage, :description, :price, :receipt, parts_attributes: [:id, :name, :price, :_destroy])
  end
end
