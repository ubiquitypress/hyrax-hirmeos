module Hyrax
  module Hirmeos
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
