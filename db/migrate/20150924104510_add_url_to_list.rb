class AddUrlToList < ActiveRecord::Migration
  def change
    add_column :lists, :url, :string
  end
end
