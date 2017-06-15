require 'sinatra'
require 'sqlite3'
require 'stripe'
require_relative 'secrets'


get '/' do
  "This is the home page."

  # connect to the database
  db = SQLite3::Database.open('store.db')

  # configure results to be returned as as an array of hashes instead of nested arrays
  db.results_as_hash = true

  # query the products table and print the result
  puts "Database query results:"
  @products = db.execute("SELECT id, description, price FROM products;")

  # close database connection
  db.close

  erb :home
end

get '/success' do
  "Your payment has processed successfully."
end

post '/pay' do

  # connect to the database
  db = SQLite3::Database.open('store.db')

  # query the products table and print the result
  @products = db.execute("SELECT id, description, price FROM products;")

  p params
  p params[:productId].to_i
  product_id = params[:productId].to_i

  amount = db.execute('SELECT price FROM products WHERE id=?', product_id)[0][0]
  p amount

  stripe_token = params[:stripeToken]

  email = params[:email]

  Stripe::Charge.create(
    :amount => amount,
    :currency => "usd",
    :source => stripe_token, # obtained with Stripe.js
    :description => email
  )

  # close database connection
  db.close

redirect '/success'

end
