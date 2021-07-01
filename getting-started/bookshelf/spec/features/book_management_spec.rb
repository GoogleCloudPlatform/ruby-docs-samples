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

require "spec_helper"

feature "Managing Books" do
  scenario "No books have been added" do
    visit "/"

    expect(page).to have_content "No books found"
  end

  scenario "Listing all books" do
    Book.create! title: "A Tale of Two Cities", author: "Charles Dickens"

    visit "/"

    expect(page).to have_content "A Tale of Two Cities"
    expect(page).to have_content "Charles Dickens"
  end

  scenario "Paginating through list of books" do
    Book.delete_all
    Book.create! title: "Book 1"
    Book.create! title: "Book 2"
    Book.create! title: "Book 3"
    Book.create! title: "Book 4"
    Book.create! title: "Book 5"

    stub_const "BooksController::PER_PAGE", 2

    visit "/"
    expect(all(".book").length).to eq 2

    click_link "More"
    expect(all(".book").length).to eq 2

    click_link "More"
    expect(all(".book").length).to eq 1

    expect(page).not_to have_link "More"
  end

  scenario "Adding a book" do
    Book.delete_all

    visit "/"
    click_link "Add Book"
    within "form.new_book" do
      fill_in "Title", with: "A Tale of Two Cities"
      fill_in "Author", with: "Charles Dickens"
      fill_in "Date Published", with: "1859-04-01"
      fill_in "Description", with: "A novel by Charles Dickens"
      click_button "Save"
    end

    expect(page).to have_content "Added Book"

    book = Book.first
    expect(book.title).to eq "A Tale of Two Cities"
    expect(book.author).to eq "Charles Dickens"
    expect(book.published_on).to eq "1859-04-01"
    expect(book.description).to eq "A novel by Charles Dickens"
  end

  scenario "Adding a book with missing fields" do
    Book.delete_all
    visit "/"
    click_link "Add Book"
    within "form.new_book" do
      click_button "Save"
    end

    expect(page).to have_content "Title can't be blank"

    within "form.new_book" do
      fill_in "Title", with: "A Tale of Two Cities"
      click_button "Save"
    end

    expect(Book.first.title).to eq "A Tale of Two Cities"
  end

  scenario "Editing a book" do
    Book.delete_all
    book = Book.create! title: "A Tale of Two Cities", author: "Charles Dickens"

    visit "/"
    click_link "A Tale of Two Cities"
    click_link "Edit Book"
    fill_in "Title", with: "CHANGED!"
    click_button "Save"

    expect(page).to have_content "Updated Book"

    book = Book.find book.id
    expect(book.title).to eq "CHANGED!"
    expect(book.author).to eq "Charles Dickens"
  end

  scenario "Editing a book with missing fields" do
    Book.delete_all
    book = Book.create! title: "A Tale of Two Cities"

    visit "/"
    click_link "A Tale of Two Cities"
    click_link "Edit Book"
    fill_in "Title", with: ""
    click_button "Save"

    expect(page).to have_content "Title can't be blank"
    book = Book.find book.id
    expect(book.title).to eq "A Tale of Two Cities"

    within "form.edit_book" do
      fill_in "Title", with: "CHANGED!"
      click_button "Save"
    end

    book = Book.find book.id
    expect(book.title).to eq "CHANGED!"
  end

  scenario "Deleting a book" do
    Book.delete_all
    book = Book.create! title: "A Tale of Two Cities", author: "Charles Dickens"
    expect(Book.exists?(book.id)).to be true

    visit "/"
    click_link "A Tale of Two Cities"
    click_link "Delete Book"

    expect(Book.exists?(book.id)).to be false
  end
end
