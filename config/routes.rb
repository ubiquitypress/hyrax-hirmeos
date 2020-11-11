# frozen_string_literal: true
Hyrax::Hirmeos::Engine.routes.draw do
  get '/works/:id/metrics_widget' => "widget#show", as: :work_metrics_widget, defaults: { type: 'work' }
  get '/files/:id/metrics_widget' => "widget#show", as: :file_set_metrics_widget, defaults: { type: 'file_set' }
end
