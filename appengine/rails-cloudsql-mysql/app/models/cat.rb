class Cat < ApplicationRecord
  validates :name, presence: true
  validates :age,  presence: true, numericality: { only_integer: true }
end
