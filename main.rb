require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'
require 'sinatra/cookies'
require 'time'

use Rack::MethodOverride
set :cookie_options, { domain: 'localhost', path: '/' }

get '/' do
  @contents = Dir.glob('files/*').map do |name|
    open(name) do |f|
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
  while File.exist?("files/#{id}")
    id = SecureRandom.hex(16)
  end

  open("files/#{id}", 'w') do |f|
    a = params.slice('title', 'body')
    a.merge('id' => id, 'time' => Time.now)
    f.write(a.to_json)
  end
  redirect "/memos/#{id}"
end

get '/memos/:id/edit' do
  if cookies[:user_id] == nil
    cookies[:user_id] = SecureRandom.hex(16)
  end

  if File.exist?("locks/#{params['id']}")
    user_id = open("locks/#{params['id']}") do |f|
      f.read
    end
    if user_id != cookies[:user_id]
      redirect '/error'
      return
    end
  end

  open("locks/#{params['id']}", 'w') do |f|
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
