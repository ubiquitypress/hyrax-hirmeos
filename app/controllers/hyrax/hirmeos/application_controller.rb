module Hyrax
  module Hirmeos
    class ApplicationController < ActionController::Base
      protect_from_forgery with: :exception
    end
  end
end
