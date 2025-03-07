class DeviseTokenAuthCreateUsers < ActiveRecord::Migration[6.0]  # ← ここが正しく指定されているか確認
    def change
      create_table :users do |t|
        ## Devise Token Auth fields
        t.string :email, null: false, default: ""
        t.string :encrypted_password, null: false, default: ""
        t.string :name
        t.string :nickname
        t.string :image
        t.string :provider, null: false, default: "email"
        t.string :uid, null: false, default: ""
  
        ## Tokens
        t.text :tokens
  
        t.timestamps
      end
  
      add_index :users, :email, unique: true
      add_index :users, [:uid, :provider], unique: true
    end
  end
  