class CreateIdentities < ActiveRecord::Migration[7.0]
  def change
    create_table :identities do |t|
      t.integer :user_id
      t.integer :network_id
      t.string :display_name

      t.timestamps
    end
  end
end
