require 'spec_helper'
require 'tmpdir'

RSpec.describe 'Kasi CLI' do
  it 'creates a new Rails application' do
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        system 'kasi new test_app'

        expect(File.directory?('test_app')).to be true
        expect(File.exist?('test_app/Gemfile')).to be true
      end
    end
  end
end
