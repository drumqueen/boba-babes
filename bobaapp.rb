require 'sinatra'
enable :sessions

require 'sqlite3'
require 'stripe'
require_relative 'bobasecrets'



get '/' do
  # connect to the database
  db = SQLite3::Database.open('boba.db')

  # configure results to be returned as as an array of hashes instead of nested arrays
  db.results_as_hash = true

  # query the places table and print the result
  puts "database result:"
  @places = db.execute("SELECT id, place FROM places;")

  # close database connection
  db.close

  erb :home

end


post '/' do
erb :bobaplaces
end


post '/bobaplaces' do

  # connect to the database
  db = SQLite3::Database.open('boba.db')

  # configure results to be returned as as an array of hashes instead of nested arrays
  db.results_as_hash = true

  # query the products table and print the result
  puts "Database query results:"
  @products = db.execute("SELECT id, description, price FROM products;")
  user_input = params[:place]

  @storename = db.execute('SELECT storename FROM places WHERE place=?', user_input)[0][0]

  # close database connection
  db.close

  erb :bobaplaces, :locals => {:place => user_input, :storename => @storename}

  end

@order = "banana"

post '/pay' do

  # connect to the database
  db = SQLite3::Database.open('boba.db')

  # configure results to be returned as as an array of hashes instead of nested arrays
  db.results_as_hash = true

  # query the products table and print the result
  @products = db.execute("SELECT id, description, price FROM products;")

  product_id = params[:productId].to_i

  amount = db.execute('SELECT price FROM products WHERE id=?', product_id)[0][0]
  p amount

  @order = db.execute('SELECT description FROM products WHERE id=?', product_id)[0][0]

  # close database connection
  db.close

  erb :pay

end


post '/success' do
  # connect to the database
  db = SQLite3::Database.open('boba.db')

  # configure results to be returned as as an array of hashes instead of nested arrays
  db.results_as_hash = true

  # query the products table and print the result
  @products = db.execute("SELECT id, description, price FROM products;")

  name = params[:name]
  p name
  p params[:order]

  #amount = db.execute('SELECT price FROM products WHERE id=?', product_id)[0][0]
   stripe_token = params[:stripeToken]


Stripe::Charge.create(
    :amount => 700,
    :currency => "usd",
    :source => stripe_token, # obtained with Stripe.js
    :description => name,
    :metadata => {'order' => params[:order]}
)
  # close database connection
  db.close

  erb :success
end
