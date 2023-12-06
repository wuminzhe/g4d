class AddPreimageToGovernances < ActiveRecord::Migration[7.0]
  def change
    add_column :governances, :preimage_id, :integer
  end
end
