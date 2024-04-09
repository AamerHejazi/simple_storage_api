class CreateAuthTokens < ActiveRecord::Migration[7.1]
  def change
    create_table :auth_tokens do |t|
      t.string :token
      t.datetime :expires_at
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :auth_tokens, :token
  end
end
