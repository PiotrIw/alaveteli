class CreateInfoRequestBatchPublicBodiesJoinTable < ActiveRecord::Migration[4.2] # 3.2
  def change
    create_table :info_request_batches_public_bodies, id: false do |t|
      t.integer :info_request_batch_id
      t.integer :public_body_id
    end
  end
end
