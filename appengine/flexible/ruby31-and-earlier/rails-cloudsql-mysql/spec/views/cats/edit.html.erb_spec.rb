# Copyright 2017 Google, Inc
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

require "rails_helper"

RSpec.describe "cats/edit", type: :view do
  before :each do
    @cat = assign(
      :cat, Cat.create!(name: "Mr. Whiskers", age: 4)
    )
  end

  it "renders the edit cat form" do
    render

    assert_select "form[action=?][method=?]", cat_path(@cat), "post" do
      assert_select "input#cat_name[name=?]", "cat[name]"

      assert_select "input#cat_age[name=?]", "cat[age]"
    end
  end
end
