# frozen_string_literal: true

RSpec.describe 'Simulation folder: MissingRequireStatement cop integration' do
  let(:cop) { RuboCop::Cop::Require::MissingRequireStatement.new(RuboCop::Config.new) }

  it 'has no offenses in all files under spec/simulations' do
    simulations_root = File.expand_path(File.join(__dir__, '..', 'simulations'))
    files = Dir[File.join(simulations_root, '**', '*.rb')].sort

    if files.empty?
      skip 'No simulation files found under spec/simulations — add .rb files to exercise multi-file requires.'
    end

    aggregate_failures 'checking simulation files' do
      files.each do |path|
        source = File.read(path)
        # Use RuboCop RSpec helper so `require_relative` can resolve using this file path
        expect_no_offenses(source, path)
      end
    end
  end
end
