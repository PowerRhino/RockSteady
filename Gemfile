source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.2.5'

gem 'aws-sdk-ecr'
gem 'haml-rails'
gem 'house_style'
gem 'http'
gem 'nomad'
gem 'pg'
gem 'puma', '~> 4.3'
gem 'rouge'
gem 'turbolinks'
gem 'webpacker', '>= 4.0.x'
gem 'webpacker-react'

group :test do
  gem 'guard-rspec'
  gem 'rspec-rails'
  gem 'simplecov'
  gem 'webmock'
end

group :test, :development do
  gem 'dotenv-rails', require: 'dotenv/rails-now'
  gem 'pry-rails'
end
