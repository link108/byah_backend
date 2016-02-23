require 'sinatra'
require 'sinatra/cross_origin'
require 'json'
require './influxdb_bridge'
require './byah_config'


configure do
  enable :cross_origin
end


config = ByahConfig.new()
influxdb = InfluxdbBridge.new(config)

puts ''


get '/data' do
  cross_origin :allow_origin => :any,
               :allow_methods => [:get],
               :allow_credentials => false,
               :max_age => "60"
  content_type :json


  series = params[:series] ? params[:series] : nil
  puts "series: #{series}"
  return [400, ''] if series.nil?
  timescale = params[:timeperiod] ? params[:timeperiod] : '7d'
  data = influxdb.query_last_n_min(series, timescale)
  puts "data: #{data}"

  temp_list = data[series].keys.inject([]) do |res, ins|
    time = Time.parse(ins).to_i
    res.push([time, data[series][ins]])
  end.sort_by { |item| item[0] } # .reverse # was item[1]
  puts ''
  puts "temp_list: #{temp_list}"
  return ok(temp_list.to_json)
end


get '*' do
  return '400'
end

def ok(message = '')
  return [200, message]
end

