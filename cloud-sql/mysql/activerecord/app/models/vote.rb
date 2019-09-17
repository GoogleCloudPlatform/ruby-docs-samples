class Vote < ApplicationRecord
  validates :candidate, inclusion: { in: ["TABS", "SPACES"] }

  def date_cast
    created_at.in_time_zone("Pacific Time (US & Canada)").strftime "%m/%d/%y"
  end

  def time_cast
    created_at.in_time_zone("Pacific Time (US & Canada)").strftime "%l:%M %p"
  end

  def self.tab_count
    where(candidate: "TABS").count
  end

  def self.space_count
    where(candidate: "SPACES").count
  end
end
