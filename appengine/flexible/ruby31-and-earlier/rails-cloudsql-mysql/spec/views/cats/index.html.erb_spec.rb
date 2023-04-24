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

RSpec.describe "cats/index", type: :view do
  before :each do
    assign(
      :cats,
      [
        Cat.create!(name: "Mr. Whiskers", age: 4),
        Cat.create!(name: "Ms. Paws", age: 2)
      ]
    )
  end

  it "renders a list of cats" do
    render
    assert_select "tr>td", text: "Mr. Whiskers".to_s, count: 1
    assert_select "tr>td", text: 4.to_s, count: 1
    assert_select "tr>td", text: "Ms. Paws".to_s, count: 1
    assert_select "tr>td", text: 2.to_s, count: 1
  end
end
