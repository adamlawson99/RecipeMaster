class AddSourceToRecipes < ActiveRecord::Migration[8.0]
  def change
    add_column :recipes, :source, :string
  end
end
