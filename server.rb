require 'pry'
require 'sinatra'
require 'sinatra/reloader'
require 'omniauth-github'
require 'dotenv'
require 'pg'
require 'flowdock'
require 'rubygems'

Dotenv.load

configure do
  enable :sessions
  set :session_secret, ENV['SESSION_SECRET']

  use OmniAuth::Builder do
    provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET']
  end
end


def user_from_omniauth(auth)
  {
    uid:auth.uid,
    id: auth.id,
    provider: auth.provider,
    username:auth.info.nickname,
    avatar_url: auth.info.image
  }
end

def connect
  begin
    connection = PG.connect(dbname: 'flowquest')
  end
end

def create_user(user_info)
  sql = "INSERT INTO users (uid,username,avatar_url) VALUES(#{user_info[:uid]},#{user_info[:username]},#{user_info[:avatar_url]})"
end

def client
  client = Flowdock::Client.new(api_token: )
end

get '/' do
  erb :index
end

get '/auth/github/callback' do
  auth = env['omniauth.auth']
  user_info = user_from_omniauth(auth)
  @flows = client.get('/flows')
  erb :home
end

get '/flow' do
  @api_token = params["token"]
  erb :post
end

post '/flow_post' do
  flow = Flowdock::Flow.new(:api_token => params["token"], source: "FlowQuest", external_user_name: "Eric")
  flow.push_to_chat(content: params["content"], tags: ["zomg","kittens!"])
  redirect '/flow'
end
