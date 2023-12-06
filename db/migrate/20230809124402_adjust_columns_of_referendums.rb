class AdjustColumnsOfReferendums < ActiveRecord::Migration[7.0]
  def change
    add_column :democracy_referendums, :user_id, :integer
    add_column :democracy_referendums, :votes, :jsonb
    remove_column :democracy_referendums, :value, :string
  end
end
