require 'rubygems'
require 'bundler/setup'

require 'pg'
require 'sequel'
require 'sinatra'
require 'sinatra/partial'
require 'tilt/erb'

set :partial_template_engine, :erb

DB = Sequel.connect(ENV.fetch('DATABASE_URL', 'postgres://localhost/seasonable'))

get '/' do
  limit = Date.today + 7

  items = DB[:items].order(:name).where{
    (
      (start_date_month < Date.today.month) |
      Sequel.&({start_date_month: Date.today.month}, start_date_day <= Date.today.day)
    ) &
    (
      (end_date_month > Date.today.month) |
      Sequel.&({end_date_month: Date.today.month}, end_date_day >= Date.today.day)
    )
  }

  @out, @today = items.partition do |item|
    item[:end_date_month] < limit.month ||
    item[:end_date_month] == limit.month && item[:end_date_day] <= limit.day
  end

  items = DB[:items].order(:start_date_month, :start_date_day).where{
    (start_date_month > Date.today.month) |
    Sequel.&({start_date_month: Date.today.month}, start_date_day > Date.today.day)
  }

  @in, @not = items.partition do |item|
    item[:start_date_month] < limit.month ||
    item[:start_date_month] == limit.month && item[:start_date_day] <= limit.day
  end

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
<%= partial(:section, locals: {header: nil, collection: @today, suffix: nil}) %>
<%= partial(:section, locals: {header: 'Out of season within a week', collection: @out, suffix: :ending}) %>
<%= partial(:section, locals: {header: 'In season within a week', collection: @in, suffix: :starting}) %>
<%= partial(:section, locals: {header: 'Not in season', collection: @not, suffix: :starting}) %>

@@section
<% if collection.any? %>
  <% if header %>
    <h2><%= header %></h2>
  <% end %>

  <% collection.each_slice(6) do |items| %>
    <div class="row">
      <% items.each_with_index do |item,index| %>
        <% if index % 6 != 0 && index % 3 == 0 %>
          <div class="clearfix visible-sm"></div>
        <% elsif index % 6 != 0 && index % 2 == 0 %>
          <div class="clearfix visible-xs"></div>
        <% end %>
        <div class="col-md-2 col-sm-4 col-xs-6" style="margin: 20px 0;">
          <p class="lead" style="text-align: center;">
            <%= item[:name].capitalize %>
            <% if suffix %>
              <%= partial(suffix, locals: {item: item}) %>
            <% end %>
          </p>
          <img src="<%= item[:image] %>" width="100%" alt="" class="img-rounded">
        </div>
      <% end %>
    </div>
  <% end %>
<% end %>

@@ending
<br>
in <%= (Date.new(Date.today.year, item[:end_date_month], item[:end_date_day]) - Date.today).to_i %> days

@@starting
<br>
in <%= (Date.new(Date.today.year, item[:start_date_month], item[:start_date_day]) - Date.today).to_i %> days
