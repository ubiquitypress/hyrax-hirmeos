# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Metrics Widget', type: :feature do
  let(:work) { create(:work) }

  it 'displays the metrics widget on the show work page' do
    visit "/concern/generic_works/#{work.id}"
    expect(page).to have_xpath('//*[@id="metrics-block"]')
  end
end
