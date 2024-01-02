# desc "Packs all CSS files from app/assets/tailwind_stylesheets into app/assets/stylesheets/application.tailwind.css then runs the tailwind build"
task twd_css_build: :environment do
  files = Dir["./app/assets/tailwind_stylesheets/**/*.css"]

  File.open("./app/assets/stylesheets/application.tailwind.css", "w") do |main_file|
    main_file.write("/* GENERATED FILE! */\n")
    main_file.write("@tailwind base;\n")
    main_file.write("@tailwind components;\n")
    main_file.write("@tailwind utilities;\n")
    main_file.write("\n")

    files.each do |file_path|
      File.open(file_path, "r") do |file|
        loop do
          main_file.write(file.readline)
        rescue StandardError
          main_file.write("\n")
          break
        end
      end
    end
  end
end


Rake::Task['tailwindcss:build'].enhance [:twd_css_build]

desc "Run tailwind:build on changes in directory app/assets/tailwind_stylesheets"

task 'twd_css_build:watch' do
  listen = Listen.to(Rails.root.join('app', 'assets', 'tailwind_stylesheets')) do
    Rake::Task[:twd_css_build].execute
    Rake::Task['tailwindcss:build'].execute
  end

  listen.start
end

Rake::Task['tailwindcss:watch'].enhance ['twd_css_build:watch']
