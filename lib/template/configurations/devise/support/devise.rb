RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::ControllerHelpers, type: :component

  config.before(:each, type: :component) do
    @request = controller.request
  end
end
