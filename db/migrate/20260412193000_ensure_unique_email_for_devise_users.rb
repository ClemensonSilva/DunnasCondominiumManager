class EnsureUniqueEmailForDeviseUsers < ActiveRecord::Migration[8.1]
  class MigrationUser < ApplicationRecord
    self.table_name = "users"
  end

  def up
    MigrationUser.where(email: [ nil, "" ]).find_each do |user|
      user.update_columns(email: "user#{user.id}@change-me.local")
    end

    duplicated_emails = MigrationUser
      .where.not(email: [ nil, "" ])
      .group(:email)
      .having("COUNT(*) > 1")
      .count
      .keys

    duplicated_emails.each do |email|
      local, domain = email.split("@", 2)
      domain ||= "change-me.local"

      MigrationUser.where(email: email).order(:id).offset(1).find_each do |user|
        user.update_columns(email: "#{local}+#{user.id}@#{domain}")
      end
    end

    change_column_null :users, :email, false
    add_index :users, :email, unique: true unless index_exists?(:users, :email)
  end

  def down
    remove_index :users, :email if index_exists?(:users, :email)
    change_column_null :users, :email, true
  end
end
