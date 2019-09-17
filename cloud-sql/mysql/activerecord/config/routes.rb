Rails.application.routes.draw do
  get "/", to: "votes#index"
  post "/", to: "votes#create"
end
