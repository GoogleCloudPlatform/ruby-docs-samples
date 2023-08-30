# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative "../app.rb"
require "rspec"
require "capybara/rspec"
require "capybara/cuprite"

describe "Cloud Storage", type: :feature do
  before do
    Capybara.current_driver = :cuprite
  end
  it "can upload and get public URL of uploaded file" do
    Capybara.app = Sinatra::Application
    file_path = File.expand_path "ruby-storage-test-upload.txt", __dir__

    visit "/"
    attach_file "file", file_path
    click_button "Upload"

    uploaded_file_public_url = page.find("body").text

    visit uploaded_file_public_url
    expect(page).to have_content "This is the content of the test-upload.txt file"
  end
end
