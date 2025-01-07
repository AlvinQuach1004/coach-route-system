class ChangeTypeNameInCoach < ActiveRecord::Migration[7.2]
  def change
    rename_column(:coaches, :type, :coach_type)
  end
end
