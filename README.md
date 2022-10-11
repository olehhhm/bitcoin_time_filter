# Solution for Bitcoin Time Series Filtering and Grouping
## Description
Main file here is `bitcoin_time_filter.rb`, it's a class that getting json and filter parameters and return result.
It's contain only one public function that need to be used for get result, it's called "filter".
---
main.rb is just simple example of running main class.
U can simple run it with `ruby main.rb` and it must work
--
In folder spec you can find some common tests.
Command to run it `rspec spec/bitcoin_time_filter_spec.rb`
But before that we need to run `bundle install`
---
## Some examples of running main class
````
p BitcoinTimeFilter.filter json: json
p BitcoinTimeFilter.filter json: json, granularity: :weekly
p BitcoinTimeFilter.filter json: json, granularity: :monthly
p BitcoinTimeFilter.filter json: json, granularity: :quarterly
p BitcoinTimeFilter.filter json: json, granularity: :quarterly, order_dir: desc
p BitcoinTimeFilter.filter json: json, granularity: :quarterly, filter_date_from: '2017-08-01'
p BitcoinTimeFilter.filter json: json, granularity: :quarterly, filter_date_from: '2017-08-01', filter_date_to: "2018-07-01"
````