require_relative '../drivy'
require 'json'
require 'rspec'
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

  describe 'price calculation' do
    describe 'given example' do

      # read input file
      input_path = File.expand_path('../data/input.json', File.dirname(__FILE__))
      input_file = File.open(input_path, 'r')
      input_data = JSON.load(input_file)
      let(:input) { input_data }
      let(:output) {
        {
            rentals: [
                {
                    id: 1,
                    price: 3000
                },
                {
                    id: 2,
                    price: 6800
                },
                {
                    id: 3,
                    price: 27800
                }
            ]
        }
      }

      it 'calculates expected output' do
        result = Drivy.process(input)
        expect(result).to eq(output)
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
            },
          ]
        }

      }

      it 'calculates expected output' do
        result = Drivy.process(input)
        expect(result).to eq(output)
      end
    end
  end
end
