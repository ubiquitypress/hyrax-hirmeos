# frozen_string_literal: true
module Hyrax
  module Hirmeos
    class WidgetController < ApplicationController
      def show
        render layout: false
      end
    end
  end
end
