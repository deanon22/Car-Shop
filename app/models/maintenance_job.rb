class MaintenanceJob < ApplicationRecord
  belongs_to :car
  has_many_attached :receipts
  
  has_many :parts, dependent: :destroy
  accepts_nested_attributes_for :parts, allow_destroy: true, reject_if: :all_blank

  def total_cost
    (price || 0) + parts.sum(:price)
  end
end
