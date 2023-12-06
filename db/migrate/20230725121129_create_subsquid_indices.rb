class CreateSubsquidIndices < ActiveRecord::Migration[7.0]
  def change
    create_table :subsquid_indices do |t|
      t.string :name
      t.string :value

      t.timestamps
    end
  end
end
