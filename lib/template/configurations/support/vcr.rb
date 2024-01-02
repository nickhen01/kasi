require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.ignore_localhost = true
  config.configure_rspec_metadata!
  config.allow_http_connections_when_no_cassette = false

  config.filter_sensitive_data('<SECRET>') do |interaction|
    auths = interaction.request.headers.fetch('Authorization', '').first
    if (match = auths.match /^Basic\s+([^,\s]+)/ )
      match.captures.first
    elsif (match = auths.match /^Bearer\s+([^,\s]+)/ )
      match.captures.first
    elsif (match = auths.match /^Token\s+([^,\s]+)/ )
      match.captures.first
    end
  end
end

