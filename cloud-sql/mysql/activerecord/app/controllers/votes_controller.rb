class VotesController < ApplicationController
  before_action :set_vote, only: [:show, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token

  def index
    @tab_count = Vote.tab_count
    @space_count = Vote.space_count
    @recent_votes = Vote.last(5).reverse
  end

  def create
    @vote = Vote.new candidate: candidate

    if @vote.save
      render json: "Vote successfully cast for \"#{@vote.candidate}\" at #{@vote.time_cast} PST!"
    else
      render json: @vote.errors, status: :unprocessable_entity
    end
  end

  private

  def candidate
    params.fetch(:candidate, {})
  end
end
