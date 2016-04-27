#The environment variable DATABASE_URL should be in the following format:
# => postgres://{user}:{password}@{host}:{port}/path
configure :production, :development do
	db = URI.parse(ENV['DATABASE_URL'] || 'postgres://localhost/wtadev')
  
  if ENV['DATABASE_URL']
  	ActiveRecord::Base.establish_connection(
  			:adapter => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
  			:host     => db.host,
  			:username => ENV['DB_USER'],
  			:password => ENV['DB_PASS'],
  			:database => db.path[1..-1],
  			:encoding => 'utf8'
  	)
  else
  	ActiveRecord::Base.establish_connection(
  			:adapter => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
  			:host     => db.host,
  			:username => 'wta',
  			:password => 'password',
  			:database => db.path[1..-1],
  			:encoding => 'utf8'
  	)
  end
end

after do
  ActiveRecord::Base.connection.close
end

