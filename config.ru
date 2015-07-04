require 'rubygems'
require 'bundler/setup'

require 'pg'
require 'sequel'
require 'sinatra'
require 'tilt/erb'

DB = Sequel.connect(ENV.fetch('DATABASE_URL', 'postgres://localhost/whatsinseason'))

get '/' do
  @items = DB[:items].where{
    (
      (start_date_month < Date.today.month) |
      Sequel.&({start_date_month: Date.today.month}, start_date_day < Date.today.day)
    ) &
    (
      (end_date_month > Date.today.month) |
      Sequel.&({end_date_month: Date.today.month}, end_date_day > Date.today.day)
    )
  }

  erb :index
end

run Sinatra::Application

__END__
@@layout
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta http-equiv="x-ua-compatible" content="ie=edge">
<title>What's in Season?</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css">
</head>
<body>
<div class="container-fluid">
<%= yield %>
</div>
</div>
</body>
</html>

@@index
<% @items.each_slice(6) do |items| %>
  <div class="row">
    <% items.each_with_index do |item,index| %>
      <% if index % 6 != 0 && index % 3 == 0 %>
        <div class="clearfix visible-sm"></div>
      <% elsif index % 6 != 0 && index % 2 == 0 %>
        <div class="clearfix visible-xs"></div>
      <% end %>
      <div class="col-md-2 col-sm-4 col-xs-6" style="margin: 20px 0;">
        <p class="lead" style="text-align: center;"><%= item[:name].capitalize %></p>
        <img src="<%= item[:image] %>" width="100%" alt="" class="img-rounded">
      </div>
    <% end %>
  </div>
<% end %>
