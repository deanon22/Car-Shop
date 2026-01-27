class CreateParts < ActiveRecord::Migration[8.0]
  def change
    create_table :parts do |t|
      t.string :name
      t.decimal :price, precision: 10, scale: 2
      t.references :maintenance_job, null: false, foreign_key: true

      t.timestamps
    end
  end
end
