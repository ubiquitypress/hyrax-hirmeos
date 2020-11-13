# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyrax::Hirmeos::WidgetController, type: :request do
  let(:id) { 'abcd1234' }

  describe 'work widget' do
    it 'returns the widget iframe' do
      get "/works/#{id}/metrics_widget"
      expect(response).to be_successful
      expect(response).to render_template('hyrax/hirmeos/widget/_work_widget_config')
    end
  end

  describe 'file set widget' do
    it 'returns the widget iframe' do
      get "/files/#{id}/metrics_widget"
      expect(response).to be_successful
      expect(response).to render_template('hyrax/hirmeos/widget/_file_set_widget_config')
    end
  end
end
