def all_trail_features

  ["Dogs allowed on leash", "Waterfalls", "Lakes", "Coast", "Good for kids", "Established campsites", "Rivers", "Ridges/passes", "Summits", "Accessible by Bus"]

end

def pagination num_of_hikes, items_per
  page_array = []
  items_page = []
  
  0.upto(num_of_hikes-1) do |num|
    if num == num_of_hikes-1
      items_page << num
      page_array << items_page
      break
    end
    
    if num % items_per != 0 || num == 0
      items_page << num
    else
      page_array << items_page
      items_page = []
      items_page << num
    end
  end
  
  return page_array
end

def get_bounds size, page
  if page == 1
    size < 99 ? max = size-1 : max = 98
    bounds = [0, max]
  else
    ( size - ( page*99 )) < 99 ? max = size-1 : max = ( (page-1) * 99) + 98
    bounds = [( (page-1) * 99), max]
  end
  
  return bounds
end

def get_subset bounds
  subset = []
  bounds[0].upto(bounds[1]) do |i|
    subset << session[:hikes][i]
  end
  return subset
end

def get_all_trail_data
  x = 0
  hikes = []
  
  50.times do |i| #set this low for testing so we don't burn thru google api limit
    doc = Nokogiri::HTML(open("http://www.wta.org/go-hiking/hikes/hike_search?title=&region=all&subregion=all&rating=0&mileage%3Aint=0&elevationgain%3Aint=0&highpoint=&searchabletext=&sort=&show_adv=0&filter=Search&b_start:int=#{x}"))
    hikes << doc.css("div.search-result-item")
    x += 30
  end
  
  return hikes
  
end

def create_records

  hikes_arr = get_all_trail_data
  existing_hikes = Hike.all.map {|h| h.hike_id }.to_set
  
  hikes_arr.each do |hikes|
    hikes.each do |hike|
      unless existing_hikes.include? Digest::MD5.hexdigest(hike.css("a").first['href'])
        record_hash = {}
        details = get_details hike.css("a").first['href']
        puts hike.css("span")[2].text.strip
        puts details
        distance = get_distance( 'car', details[:gps], 'Seattle' )
    
        record_hash.merge!( :hike_name => hike.css("span")[2].text.strip ) if hike.css("span")[2]
        record_hash.merge!( :roundtrip_distance => hike.css("span")[3].text.to_f ) if hike.css("span")[3]
        record_hash.merge!( :elevation_gain => hike.css("span")[4].text.strip.to_f ) if hike.css("span")[4]
        record_hash.merge!( :highest_point => hike.css("span")[5].text.strip.to_f ) if hike.css("span")[5]
        record_hash.merge!( :region => hike.css(".region").text ) if hike.css(".region")
        record_hash.merge!( :image_url => hike.css("img").first['src'] ) if hike.css("img")
        record_hash.merge!( :miles_from_seattle => distance[:distance] )
        record_hash.merge!( :minutes_from_seattle => distance[:duration] )
        record_hash.merge!( :hike_url => hike.css("a").first['href'] )
        record_hash.merge!( :summary => hike.css("div.listing-summary").text.strip )
        record_hash.merge!( :trail_attributes => hike.css("img").map {|i| i['title']}.compact.to_json )
        record_hash.merge!( :trailhead_coordinates => details[:gps].to_json )
        record_hash.merge!( :required_passes => details[:passes].to_json )
        record_hash.merge!( :hike_id => Digest::MD5.hexdigest(hike.css("a").first['href']) )
    
        Hike.create( record_hash )
      end
    end
  end
end

def add_transit_data hike
  data = JSON.parse hike.trailhead_coordinates
  gps = {}
  gps[:latitude] = data['latitude']
  gps[:longitude] = data['longitude']
  response = get_distance('transit', gps, "Seattle")
  if response[:duration]
    duration = response[:duration] 
    hike.update_attributes(:transit_time => duration)
    attrs = JSON.parse hike.trail_attributes
    attrs << "Accessible by Bus"
    hike.update_attributes(:trail_attributes => attrs.to_json)

  end
end

def get_details url
  page = Nokogiri::HTML(open(url))
  gps = { :latitude => page.css("span.latitude").text, :longitude => page.css("span.longitude").text }
  pass = page.css("#pass-required-info").text.strip.gsub(/pass\srequired/i, '').strip
  return { :gps => gps, :passes => pass }
  
end

def get_distance mode, gps, city #it doesn't get sent as JSON so it doesn't need to be parsed
  return {:distance => nil, :duration => nil} if gps[:latitude].empty? || gps[:longitude].empty?
    
  key = ENV['GOOGLE_KEY']
  gps = "#{gps[:latitude]},#{gps[:longitude]}"
  if mode == 'car'
    endpoint = "https://maps.googleapis.com/maps/api/distancematrix/json?origins=#{city}&destinations=#{gps}&units=imperial&key=#{key}"
  else
    endpoint = "https://maps.googleapis.com/maps/api/distancematrix/json?origins=#{city}&destinations=#{gps}&units=imperial&mode=transit&tansit_mode=bus&arrival_time=1461438000&key=#{key}"
  end
  response = Net::HTTP.get(URI(endpoint))
  data = JSON.parse response

  if data['rows'].first['elements'].first['status'] == "ZERO_RESULTS"
    return {:distance => nil, :duration => nil}
  else
    duration = data['rows'].first['elements'].first['duration']['value'] if data['rows'].first['elements'] # in seconds
    distance = data['rows'].first['elements'].first['distance']['value'] if data['rows'].first['elements'] # in km
    return {:distance => (distance*0.000621371).round(1), :duration => duration/60} #converted to miles & minutes
  end


end

