require 'spec_helper'

RSpec.describe AlaveteliPro::ActivityList::FollowupResent do
  include Rails.application.routes.url_helpers

  let(:event) { FactoryBot.create(:followup_resent_event) }
  let(:activity) { described_class.new(event) }

  describe '#description' do
    it 'gives an appropriate description' do
      expect(activity.description).
        to eq 'Your follow up to {{public_body_name}} on ' \
              '"{{info_request_title}}" was resent.'
    end
  end

  it_behaves_like "an ActivityList::Item with standard #description_urls"

  it_behaves_like "an ActivityList::Item with standard #call_to_action"

  describe '#call_to_action_url' do
    it 'returns the url of the followup' do
      expect(activity.call_to_action_url).
        to eq outgoing_message_path(event.outgoing_message)
    end
  end
end
