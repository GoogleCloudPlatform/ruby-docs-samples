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

class CatsController < ApplicationController
  before_action :set_cat, only: [:show, :edit, :update, :destroy]

  # GET /cats
  # GET /cats.json
  def index
    @cats = Cat.all
  end

  # GET /cats/1
  # GET /cats/1.json
  def show
  end

  # GET /cats/new
  def new
    @cat = Cat.new
  end

  # GET /cats/1/edit
  def edit
  end

  # POST /cats
  # POST /cats.json
  def create
    @cat = Cat.new cat_params

    respond_to do |format|
      if @cat.save
        format.html { redirect_to @cat, notice: "Cat was successfully created." }
        format.json { render :show, status: :created, location: @cat }
      else
        format.html { render :new }
        format.json { render json: @cat.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cats/1
  # PATCH/PUT /cats/1.json
  def update
    respond_to do |format|
      if @cat.update cat_params
        format.html { redirect_to @cat, notice: "Cat was successfully updated." }
        format.json { render :show, status: :ok, location: @cat }
      else
        format.html { render :edit }
        format.json { render json: @cat.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cats/1
  # DELETE /cats/1.json
  def destroy
    @cat.destroy
    respond_to do |format|
      format.html { redirect_to cats_url, notice: "Cat was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_cat
    @cat = Cat.find params[:id]
  end

  # Never trust parameters from the scary internet, only permit the allowlist through.
  def cat_params
    params.require(:cat).permit(:name, :age)
  end
end
