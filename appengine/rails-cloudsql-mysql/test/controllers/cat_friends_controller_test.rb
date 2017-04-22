require 'test_helper'

class CatFriendsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get cat_friends_index_url
    assert_response :success
  end

end
