class AddInitFieldsToGovernances < ActiveRecord::Migration[7.0]
  def change
    add_column :governances, :init_time, :datetime
    add_column :governances, :init_block, :integer
    add_column :governances, :init_user_id, :integer
    add_column :governances, :network_id, :integer
  end
end
