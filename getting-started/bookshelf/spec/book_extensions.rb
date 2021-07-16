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

# Additional methods added to the Book class for testing only.
module BookExtensions

  def all
    collection.get
  end

  def first
    from_snapspot(all.first)
  end

  def count
    all.count
  end

  def delete_all
    collection.get do |book_snapshot|
      book_snapshot.ref.delete
    end
  end

  def exists? id
    find(id).present?
  end

  def create attributes = nil
    book = Book.new attributes
    book.save
    book
  end

  def create! attributes = nil
    book = Book.new attributes
    raise "Book save failed" unless book.save
    book
  end

end
