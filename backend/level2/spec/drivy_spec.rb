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

  end
end
