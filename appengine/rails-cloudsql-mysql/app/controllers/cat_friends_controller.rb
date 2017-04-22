class CatFriendsController < ApplicationController
  def index
    @cats = Cat.all
  end
end
