class CreateMaintenanceJobs < ActiveRecord::Migration[8.0]
  def change
    create_table :maintenance_jobs do |t|
      t.datetime :date
      t.integer :mileage
      t.text :description
      t.decimal :price
      t.text :parts_used
      t.references :car, null: false, foreign_key: true

      t.timestamps
    end
  end
end
