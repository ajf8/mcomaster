class Filter < ActiveRecord::Base
  has_many :filter_members
  attr_accessible :filter_members_attributes, :name
  accepts_nested_attributes_for :filter_members
end
