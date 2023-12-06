class CreateCouncilMotions < ActiveRecord::Migration[7.0]
  def change
    create_table :council_motions do |t|
      t.integer :motion_index
      t.string :motion_hash
      t.integer :created_block
      t.integer :updated_block
      t.integer :aye_votes
      t.integer :nay_votes
      t.integer :status
      t.jsonb :proposer
      t.integer :member_count
      t.boolean :executed_success
      t.string :value
      t.string :call_module
      t.string :call_name
      t.jsonb :call_params
      t.jsonb :votes
      t.jsonb :timeline
      t.integer :network_id

      t.timestamps
    end
    add_index :council_motions, :motion_index, unique: true
    add_index :council_motions, :motion_hash, unique: true
  end
end
