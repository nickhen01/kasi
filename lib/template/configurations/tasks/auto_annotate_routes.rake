if Rails.env.development?
  task routes: :environment do
    puts `bundle exec rails routes`
  end
end
