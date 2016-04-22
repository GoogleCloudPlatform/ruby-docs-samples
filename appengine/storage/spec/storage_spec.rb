# Copyright 2015 Google, Inc
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

require File.expand_path("../../../../spec/e2e", __FILE__)
require "rspec"
require "capybara/rspec"
require "capybara/poltergeist"

Capybara.current_driver = :poltergeist

RSpec.describe "Cloud Storage on Google App Engine", type: :feature do
  before :all do
    app_yaml = File.expand_path("../../app.yaml", __FILE__)
    configuration = File.read(app_yaml)
                        .sub("<your-bucket-name>", ENV["GCLOUD_STORAGE_BUCKET"])
    File.write(app_yaml, configuration)

    @url = E2E.url
  end

  it "can upload and get public URL of uploaded file" do
    file_path = File.expand_path("../ruby-storage-test-upload.txt", __FILE__)

    visit @url
    attach_file "file", file_path
    click_button "Upload"

    uploaded_file_public_url = find("body").text

    visit uploaded_file_public_url
    expect(find("body").text).to eq(
      "This is the content of the test-upload.txt file"
    )
  end
end
