require_relative '../drivy'
require 'json'
require 'rspec'

read = lambda do |path|
  path = File.expand_path(path, File.dirname(__FILE__))
  file = File.open(path, 'r')
  JSON.load(file)
end

class Hash
  def stringify_keys
    JSON.parse(self.to_json)
  end
end

RSpec.describe Drivy do
  describe 'days calculation' do

    let(:start_date) { "2017-12-8" }
    let(:end_date) { "2017-12-10" }

    it 'can counts days including the last day' do
      expect(Drivy.rental_days(start_date, end_date)).to eq (3)
    end

    describe 'the same date as start and end' do
      let(:end_date) { "2017-12-8" }
      it 'count as one' do
        expect(Drivy.rental_days(start_date, end_date)).to eq (1)
      end
    end
  end

  describe 'commission calculation' do
    let(:price) { 900 }
    let(:days) { 1 }
    it 'works for a commission of 9 euros' do
      result = Drivy.divide_commission(price, days)
      expect(result[:insurance_fee]).to eq 450
      expect(result[:assistance_fee]).to eq 100
      expect(result[:drivy_fee]).to eq 350
    end

    describe '9 euros, two days' do
      let(:days) { 2 }
      it 'works for a commission of 9 euros' do
        result = Drivy.divide_commission(price, days)
        expect(result[:insurance_fee]).to eq 450
        expect(result[:assistance_fee]).to eq 200
        expect(result[:drivy_fee]).to eq 250
      end
    end

    describe '9 euros, three days' do
      let(:days) { 3 }
      it 'works for a commission of 9 euros' do
        result = Drivy.divide_commission(price, days)
        expect(result[:insurance_fee]).to eq 450
        expect(result[:assistance_fee]).to eq 300
        expect(result[:drivy_fee]).to eq 150
      end
    end

    describe '9 euros, five days, in this case drivy loses money according to the rules given . ' \
             'Is this ok?' do
      let(:days) { 5 }
      it 'works for a commission of 9 euros' do
        result = Drivy.divide_commission(price, days)
        expect(result[:insurance_fee]).to eq 450
        expect(result[:assistance_fee]).to eq 500
        expect(result[:drivy_fee]).to eq -50
      end
    end
  end

  describe 'price calculation' do
    describe 'given example' do
      let(:input) { read.call('../data/input.json') }
      let(:expected_output) { read.call('../data/expected_output.json') }

      it 'calculates expected output' do
        result = Drivy.process(input).stringify_keys
        expect(result).to eq(expected_output)
      end
    end

    describe 'time price calculations including discount' do

      let(:input) {
        {
            "cars" =>  [
                { "id"=> 1, "price_per_day"=> 10, "price_per_km"=> 10 }
            ],
            "rentals" => [
                # 1 day
                { "id"=> 1, "car_id"=> 1, "start_date"=> "2019-01-01", "end_date"=> "2019-01-01", "distance"=> 1 },
                # 2 days
                { "id"=> 2, "car_id"=> 1, "start_date"=> "2019-01-01", "end_date"=> "2019-01-02", "distance"=> 1 },
                # 4 days
                { "id"=> 3, "car_id"=> 1, "start_date"=> "2019-01-01", "end_date"=> "2019-01-04", "distance"=> 1 },
                # 5 days
                { "id"=> 4, "car_id"=> 1, "start_date"=> "2019-01-01", "end_date"=> "2019-01-05", "distance"=> 1 },
                # 10 days
                { "id"=> 5, "car_id"=> 1, "start_date"=> "2019-01-01", "end_date"=> "2019-01-10", "distance"=> 1 },
                # 11 days
                { "id"=> 6, "car_id"=> 1, "start_date"=> "2019-01-01", "end_date"=> "2019-01-11", "distance"=> 1 },
                # 21 days
                { "id"=> 7, "car_id"=> 1, "start_date"=> "2019-01-01", "end_date"=> "2019-01-21", "distance"=> 1 },
            ]
        }
      }

      let(:output) {
        {
          rentals: [
            {
              id: 1,
              price: 20
            },
            {
              id: 2,
              price: 29
            },
            {
              id: 3,
              price: 47
            },
            {
              id: 4,
              price: 54
            },
            {
              id: 5,
              price: 89
            },
            {
              id: 6,
              price: 94
            },
            {
              id: 7,
              price: 144
            }
          ]
        }
      }

      it 'just continue to test only prices' do
        get_prices_only = lambda do |output|
          {
            rentals: output[:rentals].map do |rental|
              {
                id: rental[:id],
                price: rental[:actions].first[:amount]
              }
            end
          }
        end

        result = Drivy.process(input)
        expect(
          get_prices_only.call(result)
        ).to eq(output)
      end
    end

    describe 'writes the output in the expected format' do
      let(:input) do
        {
          'cars' => [
            { 'id' => 1, 'price_per_day' => 10000, 'price_per_km' => 1000 }
          ],
          'rentals' => [
            # 1 day
            { 'id' => 1, 'car_id' => 1, 'start_date' => '2019-01-01', 'end_date' => '2019-01-01', 'distance' => 1 }
          ]
        }
      end
      let(:output) do
        {
          rentals: [
            {
              id: 1,
              actions: [
                {
                  who: 'driver',
                  type: 'debit',
                  amount: 11000
                },
                {
                  who: 'owner',
                  type: 'credit',
                  amount: 7700
                },
                {
                  who: "insurance",
                  type: "credit",
                  amount: 1650
                },
                {
                  who: "assistance",
                  type: "credit",
                  amount: 100
                },
                {
                  who: "drivy",
                  type: "credit",
                  amount: 1550
                }
              ]
            }
          ]
        }
      end

      it 'calculates expected output' do
        result = Drivy.process(input)
        expect(result).to eq(output)
      end
    end
  end
end
