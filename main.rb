require_relative 'bitcoin_time_filter'
require 'net/http'
require 'uri'

url = URI.parse('https://pkgstore.datahub.io/cryptocurrency/bitcoin/bitcoin_json/data/3d47ebaea5707774cb076c9cd2e0ce8c/bitcoin_json.json')
net_data = Net::HTTP.get(url)
json = JSON.parse(net_data)

p BitcoinTimeFilter.filter(
  json: json,
  order_dir: :desc,
  granularity: :quarterly,
  filter_date_from: '2017-08-01',
  filter_date_to: "2018-07-01"
)

# p BitcoinTimeFilter.filter json: json
# p BitcoinTimeFilter.filter json: json, granularity: :weekly
# p BitcoinTimeFilter.filter json: json, granularity: :monthly
# p BitcoinTimeFilter.filter json: json, granularity: :quarterly
# p BitcoinTimeFilter.filter json: json, granularity: :quarterly, order_dir: desc
# p BitcoinTimeFilter.filter json: json, granularity: :quarterly, filter_date_from: '2017-08-01'
# p BitcoinTimeFilter.filter json: json, granularity: :quarterly, filter_date_from: '2017-08-01', filter_date_to: "2018-07-01"