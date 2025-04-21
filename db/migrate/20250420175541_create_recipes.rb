class CreateRecipes < ActiveRecord::Migration[8.0]
  def change
    create_table :recipes do |t|
      t.string :title, null: false
      t.string :description, null: false
      t.string :short_description, null: false
      t.string :categories
      t.string :tags
      t.integer :servings, null: false
      t.string :ingredients, null: false
      t.string :instructions
      t.integer :calories
      t.string :macros

      t.timestamps
    end
  end
end
