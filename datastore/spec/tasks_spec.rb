# Copyright 2016 Google, Inc
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

require_relative "../tasks"
require "rspec"

describe "Datastore task list" do

  before :all do
    @project_id = ENV["GOOGLE_CLOUD_PROJECT"]
    @datastore = Google::Cloud::Datastore.new project: @project_id
    delete_tasks
  end

  after :each do
    delete_tasks
  end

  def delete_tasks
    tasks = @datastore.run @datastore.query("Task")
    @datastore.delete(*tasks.map(&:key)) unless tasks.empty?
  end

  it "creates client" do
    datastore = create_client project_id: @project_id
  end

  it "creates a task" do
    desc = "Test description."
    allow($stdout).to receive(:puts)
    id = new_task project_id: @project_id,
                    description: desc
    task = @datastore.find "Task", id
    expect(task.nil?).to be(false)
    expect(task["description"]).to eq(desc)
  end

  it "marks done" do
    task = @datastore.entity "Task" do |t|
      t["done"] = false
    end
    @datastore.save task
    id = task.key.id
    mark_done project_id: @project_id,
              task_id: id
    task = @datastore.find "Task", id
    expect(task["done"]).to be(true)
  end

  it "list_tasks" do
    task1 = @datastore.entity "Task" do |t|
      t["description"] = "Test 1."
      t["created"] = Time.now
      t["done"] = false
      t.exclude_from_indexes! "description", true
    end
    task2 = @datastore.entity "Task" do |t|
      t["description"] = "Test 2."
      t["created"] = Time.now
      t["done"] = false
      t.exclude_from_indexes! "description", true
    end
    @datastore.save task1, task2

    expect { list_tasks project_id: @project_id }.to output(/Test 1/).to_stdout
  end

  it "deletes tasks" do
    task = @datastore.entity "Task" do |t|
      t["description"] = "Test 1."
      t["created"] = Time.now
      t["done"] = false
      t.exclude_from_indexes! "description", true
    end
    @datastore.save task
    id = task.key.id
    delete_task project_id: @project_id,
                task_id: id
    task = @datastore.find "Task", id
    expect(task.nil?).to be(true)
  end
end
