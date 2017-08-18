#!/usr/bin/env ruby

require 'json'
require 'sinatra'
require 'sqlite3'
require 'stripe'

Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
publishable_key = ENV["STRIPE_PUB_KEY"]

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

# https://github.com/rails/rails/blob/8e2feedd31df969746898f22576db4d605fc9d9c/activesupport/lib/active_support/core_ext/string/output_safety.rb
JSON_ESCAPE = { "&" => '\u0026', ">" => '\u003e', "<" => '\u003c', "\u2028" => '\u2028', "\u2029" => '\u2029' }
JSON_ESCAPE_REGEXP = /[\u2028\u2029&><]/u

post '/pay' do
  @publishable_key=publishable_key
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
  @order_escaped_json = @order.to_json.gsub(JSON_ESCAPE_REGEXP, JSON_ESCAPE)

  erb :pay
end


post '/success' do
  total = params[:total]
  name = params[:name]
  stripe_token = params[:stripeToken]
  order = JSON.parse(params[:order])

  metadata = {}
  order.each_pair do |desc, item|
    metadata[desc] = item['quantity']
  end

  begin
    charge = Stripe::Charge.create(
      amount: total,
      currency: "usd",
      source: stripe_token, # obtained with Stripe.js
      description: name,
      metadata: metadata,
    )
  rescue Stripe::StripeError => e
    p e
    puts e.param
    raise
  end

  erb :success
end
