class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :url
      t.string :title
      t.text :body
      t.integer :list_id

      t.timestamps null: false
    end
  end
end
