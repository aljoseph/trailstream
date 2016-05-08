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


use Rack::Session::Pool, :expire_after => 60*60 # one hour :)


class Hike < ActiveRecord::Base
  #after_initialize :init 
end

set :port, 8080
set :static, true
set :public_folder, "static"
set :views, "views"

get '/' do
  session[:hikes] ||= Hike.where.not(minutes_from_seattle: nil, roundtrip_distance: nil, elevation_gain: nil, image_url: nil)
  session[:min_minutes] ||= 0
  session[:max_minutes] ||= 90
  session[:min_miles] ||= 0
  session[:max_miles] ||= 10
  session[:min_feet] ||= 0
  session[:max_feet] ||= 5000
  session[:trail_attributes] ||= []
  erb :index, :locals => {'total_hikes' => session[:hikes].count, 'min_minutes' => session[:min_minutes], 'max_minutes' => session[:max_minutes], 'min_miles' => session[:min_miles], 'max_miles' => session[:max_miles], 'min_feet' => session[:min_feet], 'max_feet' => session[:max_feet], 'trail_attributes' => session[:trail_attributes]}
end

get '/hikes/:page' do
  page = params[:page].to_i
  bounds = get_bounds session[:hikes].size, page
  subset = get_subset bounds
  erb :hikes, :locals => {'hikes' => subset, 'page' => page}
end

get '/filter' do 
  session[:hikes] = Hike.where.not(minutes_from_seattle: nil, 
                                   roundtrip_distance: nil, 
                                   elevation_gain: nil
                                   ).where(
                                   'minutes_from_seattle >= ?', params[:min_minutes]
                                   ).where(
                                   'minutes_from_seattle <= ?', params[:max_minutes]
                                   ).where(
                                   'roundtrip_distance >= ?', params[:min_miles]
                                   ).where(
                                   'roundtrip_distance <= ?', params[:max_miles]
                                   ).where(
                                   'elevation_gain >= ?', params[:min_feet]
                                   ).where(
                                   'elevation_gain <= ?', params[:max_feet]
                                   )
                                   
  if params[:trail_attributes]
    filtered_hikes = session[:hikes]
    params[:trail_attributes].each do |attribute|
      filtered_hikes = filtered_hikes.select {|h| h if (JSON.parse h.trail_attributes).include? attribute }
    end
    session[:hikes] = Hike.where(id: filtered_hikes.map(&:id))
  end
  
  params.each { |k,v| session[k] = v }
  
  session[:trail_attributes] = params[:trail_attributes]

  redirect '/'
end

get '/sort' do
end

get '/reset' do
  session[:hikes] = Hike.where.not(minutes_from_seattle: nil, roundtrip_distance: nil, elevation_gain: nil)
  redirect '/'
end
  