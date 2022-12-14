# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:games) do
      primary_key :id
      String      :name
      String      :remote_id, unique: true

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
