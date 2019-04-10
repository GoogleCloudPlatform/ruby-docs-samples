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

RSpec.describe CatsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/cats").to route_to("cats#index")
    end

    it "routes to #new" do
      expect(get: "/cats/new").to route_to("cats#new")
    end

    it "routes to #show" do
      expect(get: "/cats/1").to route_to("cats#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/cats/1/edit").to route_to("cats#edit", id: "1")
    end

    it "routes to #create" do
      expect(post: "/cats").to route_to("cats#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/cats/1").to route_to("cats#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/cats/1").to route_to("cats#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/cats/1").to route_to("cats#destroy", id: "1")
    end
  end
end
