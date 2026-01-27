class MaintenanceJob < ApplicationRecord
  belongs_to :car
  has_one_attached :receipt
  serialize :parts_used, coder: JSON # Keep existing data accessible if needed, or remove if migration complete. Plan says remove.
  # Removing serialize as we are moving to Part model.
  # serialize :parts_used, coder: JSON 
  
  has_many :parts, dependent: :destroy
  accepts_nested_attributes_for :parts, allow_destroy: true, reject_if: :all_blank

  def total_cost
    (price || 0) + parts.sum(:price)
  end
end
