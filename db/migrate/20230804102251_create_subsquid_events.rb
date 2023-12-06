class CreateSubsquidEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :subsquid_events do |t|
      t.integer :network_id
      t.string :sid
      # 397427-3
      t.string :index
      # Council.Proposed
      t.string :name
      # Council
      t.string :pallet_name
      # Proposed
      t.string :event_name
      t.jsonb :args
      t.integer :block_height
      t.string :block_hash
      t.string :block_timestamp
      t.integer :block_spec_version
      t.jsonb :block_events
      t.string :call_name
      t.string :call_pallet_name
      t.string :call_call_name
      t.jsonb :call_args
      t.jsonb :call_origin
      # 400955-2
      t.string :call_extrinsic_index
      t.string :call_extrinsic_hash

      t.timestamps
    end

    add_index :subsquid_events, %i[network_id sid], unique: true
    add_index :subsquid_events, %i[network_id pallet_name]
  end
end
