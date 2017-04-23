# [START cat_routes]
Rails.application.routes.draw do
  get 'cat_friends/index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'cat_friends#index'
end
# [END cat_routes]

=begin
# [START boilerplate]
Rails.application.routes.draw do
  get 'cat_friends/index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

end
# [END boilerplate]
=end

