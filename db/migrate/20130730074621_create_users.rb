class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :password_digest
      t.string :auth_token
      t.boolean :is_login
      t.integer :online_minutes

      t.timestamps
    end
  end
end
