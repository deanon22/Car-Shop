class MaintenanceJobsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_car
  before_action :set_maintenance_job, only: [:show, :edit, :update, :destroy, :attach_receipts, :delete_receipt]

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

  def attach_receipts
    files = params.dig(:maintenance_job, :receipts)
    if files.present?
      @maintenance_job.receipts.attach(files)
      redirect_to car_maintenance_job_path(@car, @maintenance_job), notice: "#{files.size} receipt(s) uploaded successfully."
    else
      redirect_to car_maintenance_job_path(@car, @maintenance_job), alert: 'Please select at least one file to upload.'
    end
  end

  def delete_receipt
    attachment = ActiveStorage::Attachment.find(params[:attachment_id])
    if attachment.record == @maintenance_job
      attachment.purge
      redirect_to car_maintenance_job_path(@car, @maintenance_job), notice: 'Receipt deleted.'
    else
      redirect_to car_maintenance_job_path(@car, @maintenance_job), alert: 'Could not delete receipt.'
    end
  end

  private

  def set_car
    @car = current_user.cars.find(params[:car_id])
  end

  def set_maintenance_job
    @maintenance_job = @car.maintenance_jobs.find(params[:id])
  end

  def maintenance_job_params
    params.require(:maintenance_job).permit(:date, :mileage, :description, :price, receipts: [], parts_attributes: [:id, :name, :price, :_destroy])
  end
end
