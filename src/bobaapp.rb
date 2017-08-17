#!/usr/bin/env ruby

require 'sinatra'
require 'sqlite3'
require 'stripe'

Stripe.api_key = ENV["STRIPE_KEY"]

get '/' do
  # connect to the database
  db = SQLite3::Database.open('boba.db')

  # configure results to be returned as as an array of hashes instead of nested arrays
  db.results_as_hash = true

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

  @products = db.execute("SELECT id, description, price FROM products;")
  user_input = params[:place]

  @storename = db.execute('SELECT storename FROM places WHERE place=?', user_input)[0][0]

  # close database connection
  db.close

  erb :bobaplaces, :locals => {:place => user_input, :storename => @storename}

end

post '/pay' do
  db = SQLite3::Database.open('boba.db')
  db.results_as_hash = true

  products = db.execute("SELECT id, description, price FROM products;")
  @order = {}
  @total = 0
  products.each do |product|
    quantity = params["product#{product['id']}"].to_i
    item_total = product['price'] * quantity
    @order[product['description']] = {
      'price' => product['price'],
      'quantity' => quantity,
      'item_total' => item_total,
    }
    @total += item_total
  end

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
