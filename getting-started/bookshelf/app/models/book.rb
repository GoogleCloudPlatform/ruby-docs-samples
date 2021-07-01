# Copyright 2019 Google LLC.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class Book
  # Add Active Model support.
  # Provides constructor that takes a Hash of attribute values.
  include ActiveModel::Model

  # Add Active Model validation support to Book class.
  include ActiveModel::Validations

  validates :title, presence: true

  attr_accessor :id
  attr_accessor :title
  attr_accessor :author
  attr_accessor :published_on
  attr_accessor :description
  attr_accessor :image_url
  attr_accessor :cover_image

  # Return a Google::Cloud::Firestore::Dataset for the configured collection.
  # The collection is used to create, read, update, and delete entity objects.
  def self.collection
    project_id = ENV["GOOGLE_CLOUD_PROJECT"]
    raise "Set the GOOGLE_CLOUD_PROJECT environment variable" if project_id.nil?

    # [START bookshelf_firestore_client]
    require "google/cloud/firestore"
    firestore = Google::Cloud::Firestore.new project_id: project_id
    @collection = firestore.col "books"
    # [END bookshelf_firestore_client]
  end

  def self.storage_bucket
    project_id = ENV["GOOGLE_CLOUD_PROJECT"]
    raise "Set the GOOGLE_CLOUD_PROJECT environment variable" if project_id.nil?

    @storage_bucket = begin
      config = Rails.application.config.x.settings
      # [START bookshelf_cloud_storage_client]
      require "google/cloud/storage"
      bucket_id = "#{project_id}_bucket"
      storage = Google::Cloud::Storage.new project_id: config["project_id"],
                                           credentials: config["keyfile"]
      bucket = storage.bucket bucket_id
      # [END bookshelf_cloud_storage_client]
      raise "bucket does not exist" if bucket.nil?
      bucket
    end
  end

  # Query Book entities from Cloud Firestore.
  #
  # returns an array of Book query results and the last book title
  # that can be used to query for additional results.
  def self.query options = {}
    query = collection.order :title
    query = query.limit options[:limit] if options[:limit]
    query = query.start_after options[:last_title] if options[:last_title]

    books = []
    begin
      query.get do |book|
        books << Book.from_snapspot(book)
      end
    rescue StandardError
      # Do nothing
    end
    books
  end

  def self.requires_pagination last_title
    if last_title
      collection # rubocop:disable Style/NumericPredicate
        .order(:title)
        .limit(1)
        .start_after(last_title)
        .get.count > 0
    end
  end

  def self.from_snapspot book_snapshot
    book = Book.new
    book.id = book_snapshot.document_id
    book_snapshot.data.each do |name, value|
      book.send "#{name}=", value if book.respond_to? "#{name}="
    end
    book
  end

  # Lookup Book by ID.  Returns Book or nil.
  def self.find id
    # [START bookshelf_firestore_client_get_book]
    book_snapshot = collection.doc(id).get
    Book.from_snapspot book_snapshot if book_snapshot.data
    # [END bookshelf_firestore_client_get_book]
  end

  # Save the book to Firestore.
  # @return true if valid and saved successfully, otherwise false.
  def save
    if valid?
      book_ref = Book.collection.doc id
      book_ref.set \
        title:        title,
        author:       author,
        published_on: published_on,
        description:  description,
        image_url:    image_url
      self.id = book_ref.document_id
      true
    else
      false
    end
  end

  def create
    upload_image if cover_image
    save
  end

  # Set attribute values from provided Hash and save to Firestore.
  def update attributes
    attributes.each do |name, value|
      send "#{name}=", value if respond_to? "#{name}="
    end
    update_image if cover_image
    save
  end

  def update_image
    delete_image if image_url
    upload_image
  end

  def upload_image
    file = Book.storage_bucket.create_file \
      cover_image.tempfile,
      "cover_images/#{id}/#{cover_image.original_filename}",
      content_type: cover_image.content_type,
      acl: "public"
    @image_url = file.public_url
  end

  def destroy
    delete_image if image_url
    book_ref = Book.collection.doc id
    book_ref.delete if book_ref
  end

  def delete_image
    image_uri = URI.parse image_url

    if image_uri.host == "#{Book.storage_bucket.name}.storage.googleapis.com"
      # Remove leading forward slash from image path
      # The result will be the image key, eg. "cover_images/:id/:filename"
      image_path = image_uri.path.sub "/", ""

      file = Book.storage_bucket.file image_path
      file.delete
    end
  end

  ##################

  def persisted?
    id.present?
  end
end
