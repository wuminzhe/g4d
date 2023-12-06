class CreateDiscussions < ActiveRecord::Migration[7.0]
  def change
    create_table :discussions do |t|
      t.string :uuid
      t.string :title
      t.text :body
      # used to find the discussion of a real step
      t.integer :network_id
      t.string :first_real_step_type
      t.string :first_real_step_key

      t.timestamps
    end
    add_index :discussions, :uuid, unique: true
    add_index :discussions,
              %i[network_id first_real_step_type first_real_step_key],
              unique: true,
              name: 'index_discussions_on_real_step_key'

    add_column :governances, :discussion_id, :integer
  end
end
