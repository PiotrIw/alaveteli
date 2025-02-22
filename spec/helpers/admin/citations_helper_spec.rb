require 'spec_helper'

RSpec.describe Admin::CitationsHelper do
  include Admin::CitationsHelper

  describe '#citation_icon' do
    subject { citation_icon(citation) }

    context 'with a journalism link' do
      let(:citation) { FactoryBot.build(:citation, type: 'journalism') }
      it { is_expected.to include('🗞️') }
      it { is_expected.to include('citation-icon--journalism') }
    end

    context 'with an academic link' do
      let(:citation) { FactoryBot.build(:citation, type: 'academic') }
      it { is_expected.to include('🎓') }
      it { is_expected.to include('citation-icon--academic') }
    end

    context 'with a generic link' do
      let(:citation) { FactoryBot.build(:citation, type: 'other') }
      it { is_expected.to include('🌐') }
      it { is_expected.to include('citation-icon--other') }
    end
  end
end
