# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'
require 'sinatra/cookies'
require 'time'

use Rack::MethodOverride
set :cookie_options, domain: 'localhost', path: '/'

get '/' do
  @contents = Dir.glob('files/*').map do |name|
    File.open(name) do |f|
      JSON.parse(f.read)
    end
  end

  erb :index
end

get '/new' do
  erb :new
end

post '/memos' do
  id = SecureRandom.hex(16)
  id = SecureRandom.hex(16) while File.exist?("files/#{id}")

  open("files/#{id}", 'w') do |f|
    a = params.slice('title', 'body')
    a = a.merge('id' => id, 'time' => Time.now)
    f.write(a.to_json)
  end
  redirect "/memos/#{id}"
end

get '/memos/:id/edit' do
  cookies[:user_id] = SecureRandom.hex(16) if cookies[:user_id].nil?

  lock_filename = "locks/#{params['id']}"

  if File.exist?(lock_filename)
    if Time.now - File.birthtime(lock_filename) > 1800
      File.delete(lock_filename)
    end
  end

  if File.exist?(lock_filename)
    user_id = File.open(lock_filename, &:read)
    if user_id != cookies[:user_id]
      redirect '/error'
      return
    end
  end

  File.open(lock_filename, 'w') do |f|
    f.write(cookies[:user_id])
  end
  @content = open("files/#{params['id']}") do |f|
    JSON.parse(f.read)
  end

  erb :edit
end

patch '/memos/:id' do
  open("files/#{params['id']}", 'w') do |f|
    a = params.slice('title', 'body', 'id', 'time')
    a['time'] = Time.now
    f.write(a.to_json)
  end
  File.delete("locks/#{params['id']}")
  redirect "/memos/#{params['id']}"
end

patch '/memos/:id/cancel' do
  File.delete("locks/#{params['id']}")
  redirect "/memos/#{params['id']}"
end

get '/memos/:id' do
  @content = open("files/#{params['id']}") do |f|
    JSON.parse(f.read)
  end

  erb :show
end

delete '/memos/:id' do
  File.delete("files/#{params['id']}")
  redirect '/'
end

get '/error' do
  erb :error
end
