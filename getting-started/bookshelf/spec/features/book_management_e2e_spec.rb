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


# TEMP: Disable bookshelf E2E tests because they use firestore which isn't
# available in the E2E project.
if false # rubocop:disable Lint/LiteralAsCondition
  require "e2e_spec_helper"

  E2E.sample_dir = "bookshelf"

  feature "Managing Books (e2e)" do
    scenario "Adding a book with missing fields (e2e)", :e2e do
      visit E2E.url
      click_link "Add Book"
      within "form.new_book" do
        click_button "Save"
      end

      expect(page).to have_content "Title can't be blank"
    end

    scenario "Adding a book (e2e)", :e2e do
      visit E2E.url

      click_link "Add Book"
      within "form.new_book" do
        fill_in "Title", with: "A Tale of Two Cities"
        fill_in "Author", with: "Charles Dickens"
        fill_in "Date Published", with: "1859-04-01"
        fill_in "Description", with: "A novel by Charles Dickens"
        click_button "Save"
      end

      expect(page).to have_content "Added Book"
      expect(page).to have_content "A Tale of Two Cities"
    end

    scenario "Listing all books (e2e)", :e2e do
      visit E2E.url

      expect(page).to have_content "A Tale of Two Cities"
      expect(page).to have_content "Charles Dickens"
    end

    scenario "Deleting a book (e2e)", :e2e do
      visit E2E.url
      first(:link, "A Tale of Two Cities").click
      click_link "Delete Book"

      expect(current_path).to eq "/books"
    end
  end
end
