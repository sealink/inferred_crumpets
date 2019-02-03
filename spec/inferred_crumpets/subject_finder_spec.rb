require "spec_helper"

RSpec.describe InferredCrumpets::SubjectFinder do
  let(:current_object) { double('current_object') }
  let(:collection) { double('collection') }
  let(:context) {
    double(current_object: current_object, collection: collection)
  }

  describe '#for_context' do
    subject { InferredCrumpets::SubjectFinder.for_context(context) }

    it 'should return current_object if defined' do
      expect(subject).to eq current_object
    end

    it 'should return collection if defined' do
      allow(context).to receive(:current_object).and_raise("boom")
      expect(subject).to eq collection
    end

    it 'should return nil if current_object and collection are not defined' do
      allow(context).to receive(:current_object).and_raise("boom")
      allow(context).to receive(:collection).and_raise("boom")
      expect(subject).to eq nil
    end
  end
end
