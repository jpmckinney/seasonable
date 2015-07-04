require 'rubygems'
require 'bundler/setup'

require 'json'

require 'chronic'
require 'faraday'
require 'nokogiri'
require 'pg'
require 'sequel'

DB = Sequel.connect(ENV.fetch('DATABASE_URL', 'postgres://localhost/whatsinseason'))

task :setup do
  DB.create_table :items do
    primary_key :id
    String :name
    Integer :start_date_month
    Integer :start_date_day
    Integer :end_date_month
    Integer :end_date_day
    String :image
  end
end

task :default do
  CLIENT = Faraday.new(url: 'https://api.shutterstock.com')
  CLIENT.basic_auth(ENV['SHUTTERSTOCK_CLIENT_ID'], ENV['SHUTTERSTOCK_CLIENT_SECRET'])

  def get(page)
    Nokogiri::HTML(Faraday.get("http://www.mangezquebec.com/en/arrivals/availibility.sn?page=#{page}").body)
  end

  def extract(doc)
    doc.xpath('//table[@class="table_dispo"]//tr[not(@class="empty")]').each do |tr|
      item = {name: tr.xpath('./td[2]').text}

      text = tr.xpath('./td[3]').text.strip
      unless text.empty?
        start_date, end_date = text.split(/\s+to\s+/).map{|text| Chronic.parse(text)}.compact
        item[:start_date_month] = start_date.month
        item[:start_date_day] = start_date.day
        item[:end_date_month] = end_date.month
        item[:end_date_day] = end_date.day
      end

      src = tr.xpath('./td[1]/img/@src')
      if src.empty?
        image = JSON.parse(CLIENT.get("/v2/images/search?fields=data(assets(preview(url))))&per_page=1&query=#{item[:name]}").body)['data'][0]['assets']['preview']['url']
      else
        image = "http://www.mangezquebec.com#{src[0].value}"
      end
      item[:image] = image

      puts JSON.pretty_generate(item)

      items = DB[:items].where(name: item[:name])
      method = items.any? ? :update : :insert
      items.send(method, item)
    end
  end

  doc = get(1)
  extract(doc)

  2.upto(doc.xpath('//a[@class="pg"]')[0].text.to_i) do |page|
    doc = get(page)
    extract(doc)
  end
end
