# Copyright 2019 Google, Inc
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

class VotesController < ApplicationController
  before_action :set_vote, only: [:show, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token

  def index
    @tab_count = Vote.tab_count
    @space_count = Vote.space_count
    @recent_votes = Vote.last(5).reverse
  end

  def create
    # [START cloud_sql_mysql_activerecord_connection]
    @vote = Vote.new candidate: candidate

    # ActiveRecord creates and executes your SQL and automatically
    # handles the opening and closing of the database connection.
    if @vote.save
      render json: "Vote successfully cast for \"#{@vote.candidate}\" at #{@vote.time_cast} PST!"
    else
      render json: @vote.errors, status: :unprocessable_entity
    end
    # [END cloud_sql_mysql_activerecord_connection]
  end

  private

  def candidate
    params.fetch(:candidate, {})
  end
end
