# Copyright 2020 Google, Inc
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

RSpec.describe VotesController, type: :controller do
  render_views

  before :all do
    Vote.delete_all

    10.times { |n| Vote.create candidate: ["TABS", "SPACES"][n % 2] }
  end

  describe "index" do
    it "displays the vote totals connecting via sql server over #{ENV['INSTANCE_HOST']}" do
      get :index
      expect(response.body).to match(/5 votes/)
      expect(response.body).to match(/5 votes/)
    end

    it "compares the vote totals via sql server over #{ENV['INSTANCE_HOST']}" do
      get :index
      expect(response.body).to match(/are evenly matched/)
      Vote.create candidate: "TABS"
      get :index
      expect(response.body).to match(/TABS are winning by 1 vote/)
      Vote.create candidate: "TABS"
      get :index
      expect(response.body).to match(/TABS are winning by 2 vote/)
      3.times { Vote.create candidate: "SPACES" }
      get :index
      expect(response.body).to match(/SPACES are winning by 1 vote/)
      Vote.create candidate: "SPACES"
      get :index
      expect(response.body).to match(/SPACES are winning by 2 votes/)
    end
  end

  describe "create" do
    it "casts a vote for a candidate via sql server over #{ENV['INSTANCE_HOST']}" do
      post :create, params: { candidate: "TABS" }
      expect(response.body).to match(/Vote successfully cast for "TABS"/)
      post :create, params: { candidate: "SPACES" }
      expect(response.body).to match(/Vote successfully cast for "SPACES"/)
    end

    it "updates the vote total via sql server over #{ENV['INSTANCE_HOST']}" do
      get :index
      expect(response.body).to match(/are evenly matched/)
      post :create, params: { candidate: "TABS" }
      get :index
      expect(response.body).to match(/TABS are winning by 1 vote/)
    end

    it "fails with invalid input via sql server over #{ENV['INSTANCE_HOST']}" do
      post :create, params: { candidate: "UNDERSCORES" }
      expect(response.body).to match(/is not included in the list/)
    end
  end
end
