class ChangePriceNameInTicket < ActiveRecord::Migration[7.2]
  def change
    rename_column(:tickets, :price, :paid_amount)
  end
end
