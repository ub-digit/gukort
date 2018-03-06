class ApplicationRecord < ActiveRecord::Base
  nilify_blanks
  self.abstract_class = true
end
