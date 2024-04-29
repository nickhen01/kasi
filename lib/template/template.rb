# Overwriting the source_paths method to contain the location of the template.
# Now methods like copy_file will accept relative paths to the template's location.
def source_paths
  [__dir__]
end

# Turning all spring processes off
run 'pgrep spring | xargs kill -9'

# GEMFILE
copy_file 'configurations/Gemfile', 'Gemfile', force: true

# Procfiles
copy_file 'configurations/Procfile', 'Procfile'
copy_file 'configurations/Procfile.dev', 'Procfile.dev'

# Layout
run 'rm app/views/layouts/application.html.erb'
copy_file 'configurations/layouts/application.html.slim', 'app/views/layouts/application.html.slim'
copy_file 'configurations/layouts/_head.html.slim', 'app/views/layouts/_head.html.slim'

# README
copy_file 'configurations/README.md', 'README.md', force: true

# Environments
development = <<-RUBY
  config.after_initialize do
    Bullet.enable        = true
    Bullet.rails_logger  = true
  end
  config.action_mailer.asset_host = Rails.application.credentials.dig(:development, :asset_host)
  config.action_mailer.default_url_options = {
    protocol: 'http',
    host: Rails.application.credentials.dig(:development, :app_host)
  }
  config.action_mailer.perform_deliveries  = true
  config.action_mailer.delivery_method     = :letter_opener
  config.hosts << /[^.]*.ngrok-free.app/
  routes.default_url_options = {
    protocol: 'http',
    host: Rails.application.credentials.dig(:development, :app_host)
  }
RUBY
environment(nil, env: 'development') do
  development
end

production = <<-RUBY
  # Mailer ====================================================================
  config.action_mailer.asset_host = Rails.application.credentials.dig(:production, :asset_host)
  config.action_mailer.default_url_options = { host: Rails.application.credentials.dig(:production, :app_host) }

  routes.default_url_options = { host: Rails.application.credentials.dig(:production, :asset_host) }
RUBY
environment(nil, env: 'production') do
  production
end

# Sidekiq
copy_file 'configurations/sidekiq.yml', 'config/sidekiq.yml'
configs = <<-RUBY
config.active_job.queue_adapter = :sidekiq
RUBY
environment configs
append_file 'config/routes.rb', <<-RUBY
require "sidekiq/web"
RUBY
route "mount Sidekiq::Web => '/sidekiq'"

# Generators
generators = <<-RUBY
  config.generators do |generate|
    generate.assets false
    generate.helper false
    generate.jbuilder false
    generate.template_engine :slim
    generate.view_specs false
    generate.routing_specs false
  end
RUBY
environment generators

# Rake tasks
copy_file 'configurations/tasks/auto_annotate_routes.rake', 'lib/tasks/auto_annotate_routes.rake'
copy_file 'configurations/tasks/tailwind.rake', 'lib/tasks/tailwind.rake'

# Gitignore
append_file '.gitignore', <<-TXT
# Ignore .env file containing credentials.
.env
# Ignore Mac and Linux file system files
*.swp
.DS_Store
# Ignore coverage results
/coverage
# Ignore idea
.idea
TXT

# Linting (Rubocop/Reek)
copy_file 'configurations/.rubocop.yml', '.rubocop.yml'
copy_file 'configurations/.reek.yml', '.reek.yml'

# CI
copy_file 'configurations/.github/workflows/ci.yml', '.github/workflows/ci.yml'

# Error pages
environment "config.exceptions_app = self.routes"
route "get '/404', to: 'errors#not_found'"
route "get '/500', to: 'errors#internal_server_error'"
copy_file 'configurations/errors/errors_controller.rb', 'app/controllers/errors_controller.rb'
copy_file 'configurations/errors/internal_server_error.html.slim', 'app/views/errors/internal_server_error.html.slim'
copy_file 'configurations/errors/not_found.html.slim', 'app/views/errors/not_found.html.slim'

########################################
# AFTER BUNDLE
########################################
after_bundle do
  # Tailwind
  run './bin/rails tailwindcss:install'
  run 'rm app/assets/stylesheets/application.css'
  create_file 'app/assets/tailwind_stylesheets/.keep'
  inject_into_file 'config/tailwind.config.js', after: "content: [\n" do <<-JAVASCRIPT
    './app/**/*.{html,js,erb,slim,haml,rb}',
    './config/initializers/**/*.{rb,erb,haml,html,slim}',
  JAVASCRIPT
  end

  # Bin/dev
  copy_file 'configurations/dev', 'bin/dev', force: true

  # DB
  rails_command 'db:drop db:create db:migrate'

  # Annotate
  generate('annotate:install')

  # Simple form
  generate('simple_form:install')
  copy_file 'configurations/scaffold/_form.html.slim', 'lib/templates/slim/scaffold/_form.html.slim'

  # Rollbar
  generate('rollbar')

  # Testing environment
  # Rspec
  generate('rspec:install')
  inject_into_file 'spec/spec_helper.rb', after: "RSpec.configure do |config|\n" do <<-RUBY
  config.filter_run_when_matching :focus
  config.profile_examples = 10
  config.order = :random
  RUBY
  end

  # RSpec support files
  inject_into_file 'spec/rails_helper.rb', after: "require 'rspec/rails'\n" do <<-RUBY
Dir[Rails.root.join('spec/support/**/*.rb')].sort.each { |file| require file }
  RUBY
  end
  copy_file 'configurations/support/factory_bot.rb', 'spec/support/factory_bot.rb'
  copy_file 'configurations/support/shoulda_matchers.rb', 'spec/support/shoulda_matchers.rb'
  copy_file 'configurations/support/time_helpers.rb', 'spec/support/time_helpers.rb'
  copy_file 'configurations/support/vcr.rb', 'spec/support/vcr.rb'
  copy_file 'configurations/support/view_component.rb', 'spec/support/view_component.rb'

  # Simplecov and other spec helpers
  prepend_to_file 'spec/spec_helper.rb' do <<-RUBY
require 'simplecov'
SimpleCov.start 'rails' do
  add_group "Components", "app/components"
  add_group "Policies", "app/policies"
end
require 'capybara/rspec'
  RUBY
  end

  # System tests config
  inject_into_file 'spec/rails_helper.rb', after: "RSpec.configure do |config|\n" do <<-RUBY
config.before(:each, type: :system) do
  driven_by :rack_test
end

config.before(:each, type: :system, js: true) do
  driven_by :selenium, using: :headless_chrome
end
  RUBY
  end

  # Devise
  ########################################
  if yes?("Would you like to install Devise?")
    gem 'devise', '~> 4.9'
    run 'bundle install'
    generate('devise:install')
    model_name = ask("What would you like the user model to be called? [user]")
    model_name = "user" if model_name.blank?
    generate "devise", model_name
    rails_command 'db:migrate'
    copy_file 'configurations/devise/support/devise.rb', 'spec/support/devise.rb'
    inject_into_file 'app/controllers/application_controller.rb', after: "class ApplicationController < ActionController::Base\n" do <<-RUBY

  before_action :authenticate_user!
    RUBY
    end

    # Pundit
    if yes?("Would you like to install Pundit?")
      gem 'pundit', "~> 2.2"
      run 'bundle install'
      generate('pundit:install')
      copy_file 'configurations/pundit/authorize.rb', 'app/controllers/concerns/authorize.rb'
      inject_into_class 'app/controllers/application_controller.rb', 'ApplicationController' do <<-RUBY
  include Authorize
      RUBY
      end

      inject_into_file 'spec/spec_helper.rb', after: "require 'capybara/rspec'\n" do <<-RUBY
require 'pundit/rspec'
      RUBY
      end
    end
  end

  # Pagy
  inject_into_class 'app/controllers/application_controller.rb', 'ApplicationController' do <<-RUBY
  include Pagy::Backend
  RUBY
  end

  inject_into_module 'app/helpers/application_helper.rb', 'ApplicationHelper' do <<-RUBY
  include Pagy::Frontend
  RUBY
  end

  # Git
  ########################################
  git :init
  git add: '.'
  git commit: "-m 'Initial commit'"

  # Audit the initial project's Gemfile.lock
  ########################################
  run 'bundle-audit'
end