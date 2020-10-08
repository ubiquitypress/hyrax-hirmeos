# frozen_string_literal: true
module Hyrax
  module Hirmeos
    class ApplicationMailer < ActionMailer::Base
      default from: 'from@example.com'
      layout 'mailer'
    end
  end
end
