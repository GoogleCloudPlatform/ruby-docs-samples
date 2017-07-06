# [START catfriends_controller]
class CatFriendsController < ApplicationController
  def index
    @cats = Cat.all
  end
end
# [END catfriends_controller]
