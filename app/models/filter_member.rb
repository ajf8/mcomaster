class FilterMember < ActiveRecord::Base
  belongs_to :filter
  attr_accessible :term, :term_key, :term_operator, :filtertype, :filter_id
end
