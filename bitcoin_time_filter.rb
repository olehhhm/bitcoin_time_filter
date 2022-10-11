require 'json'
require 'date'

class BitcoinTimeFilter
 class << self
  AVAILABLE_GRANULARITY = [:daily, :weekly, :monthly, :quarterly].freeze
  AVAILABLE_ORDER = [:asc, :desc].freeze

  def filter(
      json:,
      filter_date_from: nil,
      filter_date_to: nil,
      order_dir: :asc,
      granularity: :daily
    )
    return nil unless params_valid?(json, filter_date_from, filter_date_to, order_dir, granularity)

    result = filter_data(json, filter_date_from, filter_date_to)
    result = sum(result, granularity)
    result = calculate_average(result, granularity)
    result = sort(result, order_dir)
    decorate(result)
  end

  private

  def filter_data data, filter_date_from, filter_date_to
    return data if filter_date_from.nil? && filter_date_to.nil?

    data.filter do |item|
      (filter_date_from.nil? || item['date'] > filter_date_from) && (filter_date_to.nil? || item['date'] < filter_date_to)
    end
  end

  # summing all prices based on granularity type
  def sum(data, granularity)
    result = {}
    data.each do |item|
      next unless item.is_a? Hash

      # if date is not valid skipping it
      date = begin
        Date.parse(item['date'])
      rescue StandardError => e
        next
      end

      price = item['price(USD)']
      next if price.nil?

      price = price.to_f
      granularity_date = item_granularity_date(date, granularity)
      result[granularity_date] ||= {date: granularity_date, sum: 0.0}
      result[granularity_date][:sum] += price
    end
    result.values
  end

  def calculate_average(data, granularity)
    # if granularity is daily no need to calculate average value
    return data if granularity == :daily

    data.map do |item|
      sum = item[:sum]
      sum = sum / day_count_by_granularity(item[:date], granularity)
      item[:sum] = sum.round(2)
      item
    end
  end

  def sort(data, order)
    if order == :desc
      data.sort do |a, b|
        b[:date] <=> a[:date]
      end
    else
      data.sort do |a, b|
        a[:date] <=> b[:date]
      end
    end
  end

  #final decorate to format that needed
  def decorate(data)
    data.map do |item|
      [item[:date], item[:sum]]
    end
  end

  # basing on granularity type find first date in granularity period
  def item_granularity_date(date, granularity)
    format_to_day = lambda{|val| val.to_s.length == 1 ? "0#{val}": val}
    case granularity
    when :weekly
      wday = date.day - (date.wday - 1) % 7;
      # to handle situation when week start not from monday
      wday = 1 if wday < 1
      date.strftime("%Y-%m-#{format_to_day.call(wday)}")
    when :monthly
      date.strftime('%Y-%m-01')
    when :quarterly
      quarterly = (date.month / 3.0).ceil
      quarterly_begin_month = ((quarterly - 1) * 3) + 1
      date.strftime("%Y-#{format_to_day.call(quarterly_begin_month)}-01")
    else
      date.strftime('%Y-%m-%d')
    end
  end

  # basing on granularity type calculate count of days for finding avarage price
  def day_count_by_granularity(date, granularity)
    case granularity
    when :weekly
      7
    when :monthly
      y,m,d = date.split('-')
      Date.new(y.to_i, m.to_i, -1).day
    when :quarterly
      quarterly_begin = Date.parse(date)
      quarterly_end = quarterly_begin >> 3
      (quarterly_end - quarterly_begin).to_i
    else
      1
    end
  end

  # validating all params
  def params_valid?(json, filter_date_from, filter_date_to, order_dir, granularity)
    return false unless json.is_a? Array
    return false if json.empty?
    return false if !AVAILABLE_GRANULARITY.include?(granularity)
    return false if !AVAILABLE_ORDER.include?(order_dir)

    parsed_from = nil
    if !filter_date_from.nil?
      begin
        parsed_from = Date.parse(filter_date_from)
      rescue StandardError => e
        return false
      end
    end

    parsed_to = nil
    if !filter_date_to.nil?
      begin
        parsed_to = Date.parse(filter_date_to)
      rescue StandardError => e
        return false
      end
    end

    return false if !parsed_from.nil? && !parsed_to.nil? && parsed_from > parsed_to

    return true
  end
 end
end