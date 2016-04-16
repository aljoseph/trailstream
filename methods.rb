def trail_attributes
  ["Dogs allowed on leash", "Old growth", "Waterfalls", "Lakes", "Coast", "Mountain views", "Good for kids", "Wildflowers/Meadows", "Established campsites", "Rivers", "Ridges/passes", "Summits", "Accessible by Bus"]
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
    size < 100 ? max = size : max = 99
    bounds = [0, max]
  else
    ( size - page*100 ) < 100 ? max = size : max = (page*100)+99
    bounds = [page*100, max]
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