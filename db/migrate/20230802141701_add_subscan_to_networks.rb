class AddSubscanToNetworks < ActiveRecord::Migration[7.0]
  def change
    add_column :networks, :subscan, :string
  end
end
