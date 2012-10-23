class CreateShortenedUrls < ActiveRecord::Migration
  def change
    create_table :shortened_urls do |t|
      t.text :full_url

      t.timestamps
    end
  end
end
