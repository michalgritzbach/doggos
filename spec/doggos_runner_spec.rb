# frozen_string_literal: true

RSpec.describe DoggosRunner do
  it 'raises with no arguments' do
    expect { described_class.run }.to raise_error(ArgumentError)
  end

  it 'calls JSON generation' do
    allow_any_instance_of(Doggos).to receive(:download).and_return({})
    expect(described_class).to receive(:generate_json).once

    described_class.run(%w[dachshund hound])
  end
end
