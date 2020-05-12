class RemoveTypeFromListing < ActiveRecord::Migration[6.0]
  def change
    remove_column :listings, :type, :string
  end
end
