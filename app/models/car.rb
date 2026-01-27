class Car < ApplicationRecord
  belongs_to :user
  has_many :maintenance_jobs
end
