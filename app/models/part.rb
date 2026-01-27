class Part < ApplicationRecord
  belongs_to :maintenance_job
  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
