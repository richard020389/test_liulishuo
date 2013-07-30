class AddLoginTimesToUser < ActiveRecord::Migration
  def change
    add_column :users, :login_times, :integer
  end
end
