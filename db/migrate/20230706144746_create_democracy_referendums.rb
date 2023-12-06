class CreateDemocracyReferendums < ActiveRecord::Migration[7.0]
  def change
    create_table :democracy_referendums do |t|
      t.integer :network_id
      t.integer :referendum_index
      t.jsonb :author
      t.integer :created_block
      t.integer :updated_block
      t.integer :preimage_id
      t.string :preimage_hash # redundanted from preimage, for fast lookup
      t.integer :vote_threshold
      t.string :value
      t.integer :status
      t.integer :delay
      t.integer :end
      t.string :aye_amount, default: '0'
      t.string :nay_amount, default: '0'
      t.string :turnout
      t.boolean :executed_success
      t.string :aye_without_conviction, default: '0'
      t.string :nay_without_conviction, default: '0'
      t.jsonb :timeline
      t.string :call_module
      t.string :call_name
      t.integer :block_timestamp

      t.timestamps

      t.index %i[network_id referendum_index], unique: true
    end
  end
end
