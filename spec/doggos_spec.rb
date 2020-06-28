# frozen_string_literal: true

RSpec.describe Doggos do
  subject { described_class.new }

  before do
    allow_any_instance_of(described_class).to receive(:build_csv)
  end

  it 'processes known breed' do
    VCR.use_cassette('dachshund') do
      download = subject.download('dachshund')
      expect(download).to have_key('dachshund.csv')
    end
  end

  it 'raises for unknown breed' do
    VCR.use_cassette('unknown') do
      expect { subject.download('cat') }.to raise_error(RuntimeError)
    end
  end

  describe '#parse_breed' do
    it 'returns breed name from URL' do
      expect(
        subject.send(:parse_breed, 'https://images.dog.ceo/breeds/retriever-chesapeake/n02099849_1115.jpg')
      ).to eq('retriever-chesapeake')
    end
  end
end
