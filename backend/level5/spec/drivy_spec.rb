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

  describe 'gets option values for a given rental id' do
    let(:options) do
      [
        { "id" => 1, "rental_id" => 1, "type" => "gps" },
        { "id" => 2, "rental_id" => 1, "type" => "baby_seat" },
        { "id" => 3, "rental_id" => 2, "type" => "additional_insurance" }
      ]
    end
    describe 'options for rental id 1' do
      let(:rental_id) { 1 }
      let(:expected) { ['gps', 'baby_seat']}
      it 'gets the expected options' do
        expect(Drivy.options_for_rental_id(rental_id, options)).to eq expected
      end
    end

    describe 'options for rental id 2' do
      let(:rental_id) { 2 }
      let(:expected) { ['additional_insurance']}
      it 'gets the expected options' do
        expect(Drivy.options_for_rental_id(rental_id, options)).to eq expected
      end
    end

    describe 'options for rental id 3' do
      let(:rental_id) { 3 }
      let(:expected) { [] }
      it 'gets the expected options' do
        expect(Drivy.options_for_rental_id(rental_id, options)).to eq expected
      end
    end

  end

  describe 'options prices' do
    describe 'gps' do
      let(:options) { ['gps'] }
      describe 'calculations' do
        describe '1 day' do
          let(:days) { 1 }
          it 'calculates the total price' do
            total, baby_seat, gps, additional_insurance = Drivy.options_price(options, days)
            expect(total).to eq 500
            expect(gps).to eq 500
            expect(baby_seat).to eq 0
            expect(additional_insurance).to eq 0
          end
        end
        describe '10 days' do
          let(:days) { 10 }
          it 'calculates the total price' do
            total, baby_seat, gps, additional_insurance = Drivy.options_price(options, days)
            expect(total).to eq 5000
            expect(gps).to eq 5000
            expect(baby_seat).to eq 0
            expect(additional_insurance).to eq 0
          end
        end
      end
    end

    describe 'additional_insurance' do
      let(:options) { ['additional_insurance'] }
      describe 'calculations' do
        describe '1 day' do
          let(:days) { 1 }
          it 'calculates the total price' do
            total, baby_seat, gps, additional_insurance = Drivy.options_price(options, days)
            expect(total).to eq 1000
            expect(gps).to eq 0
            expect(baby_seat).to eq 0
            expect(additional_insurance).to eq 1000
          end
        end
        describe '10 days' do
          let(:days) { 10 }
          it 'calculates the total price' do
            total, baby_seat, gps, additional_insurance = Drivy.options_price(options, days)
            expect(total).to eq 10000
            expect(gps).to eq 0
            expect(baby_seat).to eq 0
            expect(additional_insurance).to eq 10000
          end
        end
      end
    end

    describe 'baby_seat' do
      let(:options) { ['baby_seat'] }
      describe 'calculations' do
        describe '1 day' do
          let(:days) { 1 }
          it 'calculates the total price' do
            total, baby_seat, gps, additional_insurance = Drivy.options_price(options, days)
            expect(total).to eq 200
            expect(gps).to eq 0
            expect(baby_seat).to eq 200
            expect(additional_insurance).to eq 0
          end
        end
        describe '10 days' do
          let(:days) { 10 }
          it 'calculates the total price' do
            total, baby_seat, gps, additional_insurance = Drivy.options_price(options, days)
            expect(total).to eq 2000
            expect(gps).to eq 0
            expect(baby_seat).to eq 2000
            expect(additional_insurance).to eq 0
          end
        end
      end
    end

    describe 'combine all options' do
      let(:options) {['gps', 'baby_seat', 'additional_insurance']}
      describe '1 day' do
        let(:days) { 1 }
        it 'calculates the total price' do
          total, baby_seat, gps, additional_insurance = Drivy.options_price(options, days)
          expect(total).to eq 1700
          expect(gps).to eq 500
          expect(baby_seat).to eq 200
          expect(additional_insurance).to eq 1000
        end
      end
      describe '10 days' do
        let(:days) { 10 }
        it 'calculates the total price' do
          total, baby_seat, gps, additional_insurance = Drivy.options_price(options, days)
          expect(total).to eq 17_000
          expect(gps).to eq 5_000
          expect(baby_seat).to eq 2_000
          expect(additional_insurance).to eq 10_000
        end
      end
    end

    describe 'none' do
      let(:options){ [] }
      describe '1 day' do
        let(:days) { 1 }
        it 'calculates the total price' do
          total, baby_seat, gps, additional_insurance = Drivy.options_price(options, days)
          expect(total).to eq 0
          expect(gps).to eq 0
          expect(baby_seat).to eq 0
          expect(additional_insurance).to eq 0
        end
      end
      describe '10 days' do
        let(:days) { 10 }
        it 'calculates the total price' do
          total, baby_seat, gps, additional_insurance = Drivy.options_price(options, days)
          expect(total).to eq 0
          expect(gps).to eq 0
          expect(baby_seat).to eq 0
          expect(additional_insurance).to eq 0
        end
      end
    end
  end

  describe 'commission calculation' do
    let(:price) { 900 }
    let(:days) { 1 }
    it 'works for a commission of 9 euros' do
      insurance, assistance, drivy = Drivy.divide_commission(price, days)
      expect(insurance).to eq 450
      expect(assistance).to eq 100
      expect(drivy).to eq 350
    end

    describe '9 euros, two days' do
      let(:days) { 2 }
      it 'works for a commission of 9 euros' do
        insurance, assistance, drivy = Drivy.divide_commission(price, days)
        expect(insurance).to eq 450
        expect(assistance).to eq 200
        expect(drivy).to eq 250
      end
    end

    describe '9 euros, three days' do
      let(:days) { 3 }
      it 'works for a commission of 9 euros' do
        insurance, assistance, drivy = Drivy.divide_commission(price, days)
        expect(insurance).to eq 450
        expect(assistance).to eq 300
        expect(drivy).to eq 150
      end
    end

    describe '9 euros, five days, in this case drivy loses money according to the rules given . ' \
             'Is this ok?' do
      let(:days) { 5 }
      it 'works for a commission of 9 euros' do
        insurance, assistance, drivy = Drivy.divide_commission(price, days)
        expect(insurance).to eq 450
        expect(assistance).to eq 500
        expect(drivy).to eq -50
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
            ],
            'options' => []
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
          ],
          'options' => []
        }
      end
      let(:output) do
        {
          rentals: [
            {
              id: 1,
              options: [],
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

  describe 'exceptions' do
    describe 'cars is nil' do
      let (:input) do
        {
            "cars": [
            ],
            "rentals": [
                { "id": 1, "car_id": 1, "start_date": "2015-12-8", "end_date": "2015-12-8", "distance": 100 },
            ],
            "options" => []
        }
      end

      it 'throws an exception' do
        expect{Drivy.process(input)}.to raise_exception(ArgumentError).with_message(
            "\"input['cars']\" was not an Array. input['cars'] => #{input['cars'].inspect}."
        )
      end
    end

    describe 'cars is not an array' do
      let (:input) do
        {
            "cars" => 'whatever',
            "rentals" => [
                { "id" =>  1, "car_id" => 1, "start_date" => "2015-12-8", "end_date" => "2015-12-8", "distance" => 100 },
            ],
            'options' => []
        }
      end

      it 'throws an exception' do
        expect{Drivy.process(input)}.to raise_exception(ArgumentError).with_message(
            "\"input['cars']\" was not an Array. input['cars'] => #{input['cars'].inspect}."
        )
      end
    end

    describe 'some car_id is not present in cars array' do
      let(:input) do
        {
            "cars"=>[
                {"id"=>1, "price_per_day"=>2000, "price_per_km"=>10}
            ],
            "rentals" => [
                {"id"=>1, "car_id"=>3, "start_date"=>"2015-12-8", "end_date"=>"2015-12-8", "distance"=>100},
                {"id"=>2, "car_id"=>4, "start_date"=>"2015-03-31", "end_date"=>"2015-04-01", "distance"=>300}
            ],
            'options' => []
        }
      end
      it 'throws an exception' do
        expect{Drivy.process(input)}.to raise_exception(ArgumentError).with_message(
            "rental['car_id'] => 3 resulted in nil while looking up in Drivy.cars. Seems like that id not present in 'input['cars']'"
        )
      end
    end

    describe 'options is not an Array' do
      let(:input) do
        {
            "cars"=>[
                {"id"=>1, "price_per_day"=>2000, "price_per_km"=>10}
            ],
            "rentals" => [
                {"id"=>1, "car_id"=>1, "start_date"=>"2015-12-8", "end_date"=>"2015-12-8", "distance"=>100},
                {"id"=>2, "car_id"=>1, "start_date"=>"2015-03-31", "end_date"=>"2015-04-01", "distance"=>300}
            ]
        }
      end
      it 'throws an exception' do
        expect{Drivy.process(input)}.to raise_exception(ArgumentError).with_message(
            "\"input['options']\" was not an Array. input['options'] => #{input['options'].inspect}."
        )
      end
    end

    describe 'rentals is not an Array' do
      let(:input) do
        {
            "cars"=>[
                {"id"=>1, "price_per_day"=>2000, "price_per_km"=>10}
            ],
            'options' => []
        }
      end
      it 'throws an exception' do
        expect{Drivy.process(input)}.to raise_exception(ArgumentError).with_message(
            "\"input['rentals']\" was not an Array. input['rentals'] => #{input['rentals'].inspect}."
        )
      end
    end
  end
end
