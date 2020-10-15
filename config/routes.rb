# frozen_string_literal: true
Hyrax::Hirmeos::Engine.routes.draw do
   Rails.application.routes.default_url_options[:host] = 'localhost:3000' #This will certainly have to be moved
end
