require 'sinatra'
require 'active_record'
require 'active_support/all'
require 'json'
require 'net/http'
require_relative 'methods'
require 'sinatra/activerecord'
require './environments'
require 'digest/md5'
require 'nokogiri'
require 'open-uri'
require 'gon-sinatra'
Sinatra::register Gon::Sinatra


use Rack::Session::Pool, :expire_after => 60*60


class Hike < ActiveRecord::Base
  #after_initialize :init 
end

set :port, 8080
set :static, true
set :public_folder, "static"
set :views, "views"

get '/' do
  session[:hikes] ||= Hike.where.not(minutes_from_seattle: nil, roundtrip_distance: nil, elevation_gain: nil)
  erb :index
end

get '/hikes/:page' do
  page = params[:page].to_i
  bounds = get_bounds session[:hikes].size, page
  subset = get_subset bounds
  erb :hikes, :locals => {'hikes' => subset, 'page' => page}
end