require "sinatra"
require "sinatra/activerecord"

if ENV['RACK_ENV']
  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
else
  set :database, {adapter: "sqlite3", database: "database.sqlite3"}
end



enable :sessions

class User < ActiveRecord::Base
end

class Post < ActiveRecord::Base
end

get "/" do
  erb :home
  # puts "running"
end

get "/signup" do
  @user = User.new
  erb :'user/signup'
  if session[:user_id]
    redirect "/"
  else
    erb :'user/signup'
  end
end

post "/signup" do
@user = User.new(params)
if @user.save
  p "#{@user.first_name} was saved to the database"
  redirect "/thanks"
end
end


get "/thanks" do
  erb :'/user/thanks'
end

get "/user/login" do
  if session[:user_id]
    redirect "/"
  else
    erb :'/user/login'
  end
end
post "/user/login" do
  user = User.find_by(email: params[:email])
  p user.password
  p params[:password]
  if user.password == params[:password]
    session[:user_id] = user.id
    redirect "/user/post"
  else
    redirect "/user/login"
  end
end

get '/search' do
  erb :'search'
end

post "/login" do
  given_password = params['password']
  user = User.find_by(email: params['email'])
  if user
    if user.password == given_password
      p "User authenticated successfully!"
      session[:user_id] = user.id
    else
      p "Invalid email or pasword"
    end
  end

end
get '/user/post' do
  @post = Post.all
  erb :'/user/post'
end

post '/user/post' do
  p params
  params.merge!(user_id: session[:user_id])
  @post = Post.new(params)
  @post.save
  redirect '/user/feeds'
end
get "/user/feeds" do
  @post = Post.all
  erb :'/user/feeds'
end
#Delete request
post '/logout'do
  session.clear
  p "user logged out successfully"
  redirect "/"
end
