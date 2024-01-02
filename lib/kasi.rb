# frozen_string_literal: true

require_relative "kasi/version"
require 'rails/generators'
require "rails/generators/rails/app/app_generator"

class Rails::Generators::AppGenerator
  alias parent_source_paths source_paths
  def source_paths
    ["#{__dir__}/templates", *parent_source_paths]
  end
end

module Kasi
  class Error < StandardError; end
end
