class CreateTwittersessions < ActiveRecord::Migration
  def change
    create_table :twittersessions do |t|

      t.timestamps
    end
  end
end
