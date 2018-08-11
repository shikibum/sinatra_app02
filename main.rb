require 'sinatra'

use Rack::MethodOverride

class Memo
end


get '/' do
  Dir.open()
  # dir = Dir.glob('memos')
  # dir.each do |title|
  #   @title = title
  # end
  erb :index
end

get '/new' do
  erb :new
end

post "/new" do 
  str = STDIN.gets
  File.open("/memos/#{$stdin}.txt", 'w'){|f|
     f.puts str
   }
  redirect '/'
  erb :new
end

# get '/memos/:id/edit' do
#   @memo = Memo.find(params['id'])
#   erb :edit
# end

# patch '/memos/:id/edit' do
#   @memo = Memo.find(params['id'])
#   @memo.update(title: params['title'], body: params['body'])
#   erb :show
# end

# get "/memos/:id" do
#   @memo = Memo.find(params['id'])
#   erb :show
# end

# delete '/memos/:id' do
#   Memo.find(params['id']).destroy
#   redirect '/'
# end