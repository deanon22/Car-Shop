class PartsController < ApplicationController
  before_action :set_maintenance_job
  before_action :set_part, only: [:edit, :update, :destroy]

  def new
    @part = @maintenance_job.parts.build
  end

  def create
    @part = @maintenance_job.parts.build(part_params)
    if @part.save
      redirect_to car_maintenance_job_path(@maintenance_job.car, @maintenance_job), notice: 'Part was successfully added.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @part.update(part_params)
      redirect_to car_maintenance_job_path(@maintenance_job.car, @maintenance_job), notice: 'Part was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @part.destroy
    redirect_to car_maintenance_job_path(@maintenance_job.car, @maintenance_job), notice: 'Part was successfully removed.'
  end

  private

  def set_maintenance_job
    @maintenance_job = MaintenanceJob.find(params[:maintenance_job_id])
  end

  def set_part
    @part = @maintenance_job.parts.find(params[:id])
  end

  def part_params
    params.require(:part).permit(:name, :price)
  end
end
