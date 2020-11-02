# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Metrics Widget', type: :feature, js: true do
  let(:work) { create(:work, visibility: 'open') }

  it 'displays the metrics widget on the show work page' do
    visit "/concern/generic_works/#{work.id}"
    expect(page).to have_xpath('//*[@id="content-wrapper"]/iframe')
  end
end
