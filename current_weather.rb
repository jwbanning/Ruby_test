require "uri"
require "net/http"

url = URI("https://api.weatherapi.com/v1/current.json?q=string&aqi=no&pollen=no&lang=string&current_fields=string&key=03f6c231e306443a988171848241801")

https = Net::HTTP.new(url.host, url.port)
https.use_ssl = true

request = Net::HTTP::Get.new(url)
request["Accept"] = "application/json"

response = https.request(request)
puts response.read_body
