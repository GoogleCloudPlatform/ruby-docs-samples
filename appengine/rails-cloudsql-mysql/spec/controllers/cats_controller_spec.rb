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

RSpec.describe CatsController, type: :controller do
  let :valid_attributes do
    { name: "Ms. Tiger", age: 3 }
  end

  let :invalid_attributes do
    { name: nil, age: nil }
  end

  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all cats as @cats" do
      cat = Cat.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(assigns(:cats)).to include(cat)
    end
  end

  describe "GET #show" do
    it "assigns the requested cat as @cat" do
      cat = Cat.create! valid_attributes
      get :show, params: { id: cat.to_param }, session: valid_session
      expect(assigns(:cat)).to eq(cat)
    end
  end

  describe "GET #new" do
    it "assigns a new cat as @cat" do
      get :new, params: {}, session: valid_session
      expect(assigns(:cat)).to be_a_new(Cat)
    end
  end

  describe "GET #edit" do
    it "assigns the requested cat as @cat" do
      cat = Cat.create! valid_attributes
      get :edit, params: { id: cat.to_param }, session: valid_session
      expect(assigns(:cat)).to eq(cat)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Cat" do
        expect {
          post :create, params: { cat: valid_attributes }, session: valid_session
        }.to change(Cat, :count).by(1)
      end

      it "assigns a newly created cat as @cat" do
        post :create, params: { cat: valid_attributes }, session: valid_session
        expect(assigns(:cat)).to be_a(Cat)
        expect(assigns(:cat)).to be_persisted
      end

      it "redirects to the created cat" do
        post :create, params: { cat: valid_attributes }, session: valid_session
        expect(response).to redirect_to(Cat.last)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved cat as @cat" do
        post :create, params: { cat: invalid_attributes }, session: valid_session
        expect(assigns(:cat)).to be_a_new(Cat)
      end

      it "re-renders the 'new' template" do
        post :create, params: { cat: invalid_attributes }, session: valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let :new_attributes do
        { name: "Mr. Whiskers", age: 4 }
      end

      it "updates the requested cat" do
        cat = Cat.create! valid_attributes
        put :update, params: { id: cat.to_param, cat: new_attributes }, session: valid_session
        cat.reload
        expect(cat.name).to eq("Mr. Whiskers")
        expect(cat.age).to eq(4)
      end

      it "assigns the requested cat as @cat" do
        cat = Cat.create! valid_attributes
        put :update, params: { id: cat.to_param, cat: valid_attributes }, session: valid_session
        expect(assigns(:cat)).to eq(cat)
      end

      it "redirects to the cat" do
        cat = Cat.create! valid_attributes
        put :update, params: { id: cat.to_param, cat: valid_attributes }, session: valid_session
        expect(response).to redirect_to(cat)
      end
    end

    context "with invalid params" do
      it "assigns the cat as @cat" do
        cat = Cat.create! valid_attributes
        put :update, params: { id: cat.to_param, cat: invalid_attributes }, session: valid_session
        expect(assigns(:cat)).to eq(cat)
      end

      it "re-renders the 'edit' template" do
        cat = Cat.create! valid_attributes
        put :update, params: { id: cat.to_param, cat: invalid_attributes }, session: valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested cat" do
      cat = Cat.create! valid_attributes
      expect {
        delete :destroy, params: { id: cat.to_param }, session: valid_session
      }.to change(Cat, :count).by(-1)
    end

    it "redirects to the cats list" do
      cat = Cat.create! valid_attributes
      delete :destroy, params: { id: cat.to_param }, session: valid_session
      expect(response).to redirect_to(cats_url)
    end
  end
end
