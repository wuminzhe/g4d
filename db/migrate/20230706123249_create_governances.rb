class CreateGovernances < ActiveRecord::Migration[7.0]
  def change
    create_table :governances do |t|
      t.string :title
      t.text :body

      t.timestamps
    end
  end
end
