class AddUuidToGovernances < ActiveRecord::Migration[7.0]
  def change
    add_column :governances, :uuid, :string, unique: true
  end
end
