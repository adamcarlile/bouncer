require 'spec_helper'

RSpec.describe Bouncer::Session do
  let(:last_checked_at)   { Time.now }
  let(:session)           { Fabricate(:session, checked_at: last_checked_at) }

  context 'complete, current, recently verified sessions' do

    it 'is current' do
      expect(session.current?).to be_truthy
    end

    it 'is refreshable' do
      expect(session.refreshable?).to be_truthy
    end

  end

  context 'a session outside the grace period' do
    let(:last_checked_at) { 3.hours.ago }

    it 'is no longer current' do
      stub_request(:get, "http://localhost:3000/oauth/token/info.json").
        to_return(status: 404)
      expect(session.current?).to be_falsey
    end
  end

end