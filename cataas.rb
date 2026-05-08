#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'uri'

class CataaS
  BASE_URL = 'https://cataas.com'
  
  # Initialize the client
  def initialize
    @base_uri = URI(BASE_URL)
  end
  
  # Get a random cat image URL
  def get_random_cat
    uri = @base_uri.dup
    uri.path = '/cat'
    make_api_request(uri)
  end
  
  # Get a random cat with a specific tag
  def get_cat_by_tag(tag)
    uri = @base_uri.dup
    uri.path = "/cat/#{tag}"
    make_api_request(uri)
  end
  
  # Get a random cat GIF
  def get_random_gif
    uri = @base_uri.dup
    uri.path = '/cat/gif'
    make_api_request(uri)
  end
  
  # Get a random cat saying text
  def get_cat_saying(text, font_size = 50, font_color = 'white')
    uri = @base_uri.dup
    uri.path = "/cat/says/#{text}"
    uri.query = "fontSize=#{font_size}&fontColor=#{font_color}"
    make_api_request(uri)
  end
  
  # Get all available tags
  def get_all_tags
    uri = @base_uri.dup
    uri.path = '/api/tags'
    response = make_api_request(uri)
    JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)
  end
  
  # Get cats with specific tags (JSON format)
  def search_cats(tags:, skip: 0, limit: 10)
    tags_param = tags.is_a?(Array) ? tags.join(',') : tags
    uri = @base_uri.dup
    uri.path = '/api/cats'
    uri.query = "tags=#{tags_param}&skip=#{skip}&limit=#{limit}"
    
    response = make_api_request(uri)
    JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)
  end
  
  # Get a random cat with custom filter and options
  def get_cat_with_filter(filter: 'mono', brightness: nil, saturation: nil, hue: nil)
    uri = @base_uri.dup
    uri.path = '/cat'
    query_parts = ["filter=#{filter}"]
    query_parts << "brightness=#{brightness}" if brightness
    query_parts << "saturation=#{saturation}" if saturation
    query_parts << "hue=#{hue}" if hue
    uri.query = query_parts.join('&')
    
    make_api_request(uri)
  end
  
  private
  
  def make_api_request(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri)
    request['Accept'] = 'application/json'
    
    begin
      response = http.request(request)
      puts "Status: #{response.code}"
      response
    rescue StandardError => e
      puts "Error: #{e.message}"
      nil
    end
  end
end

# Example usage
if __FILE__ == $0
  client = CataaS.new
  
  puts "=" * 50
  puts "CataaS - Cat as a Service API Client"
  puts "=" * 50
  
  # Get a random cat
  puts "\n1. Getting a random cat..."
  random_cat = client.get_random_cat
  puts "Random cat URL: #{random_cat.uri}" if random_cat
  
  # Get a random cat with specific tag
  puts "\n2. Getting a random 'cute' cat..."
  cute_cat = client.get_cat_by_tag('cute')
  puts "Cute cat URL: #{cute_cat.uri}" if cute_cat
  
  # Get a random cat GIF
  puts "\n3. Getting a random cat GIF..."
  gif_cat = client.get_random_gif
  puts "Cat GIF URL: #{gif_cat.uri}" if gif_cat
  
  # Get all available tags
  puts "\n4. Getting all available tags..."
  tags = client.get_all_tags
  if tags
    puts "Available tags (first 10): #{tags.first(10).join(', ')}"
    puts "Total tags: #{tags.length}"
  end
  
  # Search cats with specific tags
  puts "\n5. Searching for cute cats..."
  cats = client.search_cats(tags: 'cute', limit: 5)
  if cats
    puts "Found #{cats.length} cute cat(s)"
    cats.each_with_index do |cat, index|
      puts "  #{index + 1}. #{cat['_id']} - Tags: #{cat['tags'].join(', ')}"
    end
  end
  
  # Get a cat saying something
  puts "\n6. Getting a cat saying 'Hello Ruby!'..."
  cat_saying = client.get_cat_saying('Hello%20Ruby%21')
  puts "Cat saying URL: #{cat_saying.uri}" if cat_saying
  
  # Get a filtered cat
  puts "\n7. Getting a filtered cat (mono filter)...,.... John loves cats"
  filtered_cat = client.get_cat_with_filter(filter: 'mono')
  puts "Filtered cat URL: #{filtered_cat.uri}" if filtered_cat
end
