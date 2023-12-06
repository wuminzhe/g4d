class AddUserIdToPreimages < ActiveRecord::Migration[7.0]
  def change
    add_column :preimages, :user_id, :integer
    remove_column :preimages, :author, :jsonb
  end
end
