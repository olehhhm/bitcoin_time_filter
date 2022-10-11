require_relative '../bitcoin_time_filter'

describe BitcoinTimeFilter do
  it "responds to '.filter'" do
    expect(described_class).to respond_to(:filter)
  end

  describe '.filter' do
    context 'when parameters not valid' do
      let(:invalid_json) {nil}
      context 'when json is not valid' do
        it 'returns nil' do
          expect(described_class.filter(json: invalid_json)).to eq(nil)
        end
      end

      let(:valid_json) {[{}]}
      context 'when filter_date_from is not valid' do
        it 'returns nil' do
          expect(BitcoinTimeFilter.filter(json: valid_json, filter_date_from: '2022-2022-2022')).to eq(nil)
        end
      end

      context 'when filter_date_to is not valid' do
        it 'returns nil' do
          expect(BitcoinTimeFilter.filter(json: valid_json, filter_date_to: '2022-2022-2022')).to eq(nil)
        end
      end

      context 'when order_dir is not valid' do
        it 'returns nil' do
          expect(BitcoinTimeFilter.filter(json: valid_json, order_dir: :test)).to eq(nil)
        end
      end

      context 'when quarterly is not valid' do
        it 'returns nil' do
          expect(BitcoinTimeFilter.filter(json: valid_json, granularity: :test)).to eq(nil)
        end
      end
    end

    context 'when parameters is valid' do
    end
  end
  context 'when parameters is valid' do
    json = JSON.parse(File.read(File.join(File.dirname(__FILE__), 'mock.json')))

    json_summed_daily_in_asc_order = json.group_by{|val| val['date']}
                                         .map{|k,v| [k, v.sum{|item| item['price(USD)']}]}
                                         .sort_by{|val| val[0]}
    context 'when passed only json' do
      it 'calculating price sum with daily granularity and asc sorting by date' do
        expect(described_class.filter(json: json)).to eq(
          json_summed_daily_in_asc_order
        )
      end
    end

    context 'when passed order parameter' do
      it 'calculating price sum with daily granularity and asc sorting by date' do
        expect(described_class.filter(json: json, order_dir: :desc)).to eq(
          json_summed_daily_in_asc_order.reverse
        )
      end
    end

    context 'when passed granularity' do
      context 'when granularity is set to weekly' do
        it 'filter json, group data by week and calculate average by 7' do
          expect(described_class.filter(json: json, granularity: :weekly)).to eq(
            [["2022-01-10", 114.29], ["2022-02-01", 57.14], ["2022-02-21", 14.29], ["2022-03-14", 171.43]]
          )
        end
      end

      context 'when granularity is set to monthly' do
        it 'filter json, group data by month and calculate average by month day count' do
          sum = json.group_by{|val| Date.parse(val['date'])
                    .strftime('%Y-%m-01')}
                    .map{|k,v| [k, v.sum{|item| item['price(USD)']}]}
                    .sort_by{|val| val[0]}
                    sum = json.group_by{|val| Date.parse(val['date']) .strftime('%Y-%m-01')} .map{|k,v| [k, v.sum{|item| item['price(USD)']}]} .sort_by{|val| val[0]}
          days = [31, 28, 31]
          json_summed_by_month = sum.each_with_index.map{ |value, index| [value[0], (value[1].to_f/days[index]).ceil(2)]}
          expect(described_class.filter(json: json, granularity: :monthly)).to eq(
            json_summed_by_month
          )
        end
      end

      context 'when granularity is set to quarterly' do
        it 'filter json, group data by quarterly and calculate average by quarterly day count' do
          calculated_by_quarterly = (json.sum{|val| val['price(USD)']}/90.00).ceil(2)
          expect(described_class.filter(json: json, granularity: :quarterly)).to eq(
            [["2022-01-01", calculated_by_quarterly]]
          )
        end
      end
    end

    context 'when passed date filters' do
      it 'calculating only records that in date range' do
        date_from = '2022-02-03'
        date_to = '2022-02-07'
        filtered_and_summed = json.filter{|val| val['date'] > date_from && val['date'] < date_to}
            .group_by{|val| val['date']}
            .map{|k,v| [k, v.sum{|item| item['price(USD)']}]}
            .sort_by{|val| val[0]}
        expect(described_class.filter(json: json, filter_date_from: date_from, filter_date_to: date_to)).to eq(
          filtered_and_summed
        )
      end
    end
  end
end