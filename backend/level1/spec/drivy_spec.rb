require '../drivy'
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
      let(:input) {
        {
          "cars" => [
            {"id"=> 1, "price_per_day"=> 2000, "price_per_km"=> 10},
            {"id"=> 2, "price_per_day"=> 3000, "price_per_km"=> 15},
            {"id"=> 3, "price_per_day"=> 1700, "price_per_km"=> 8}
          ],
          "rentals"=> [
            {"id"=> 1, "car_id"=> 1, "start_date"=> "2017-12-8", "end_date"=> "2017-12-10", "distance"=> 100},
            {"id"=> 2, "car_id"=> 1, "start_date"=> "2017-12-14", "end_date"=> "2017-12-18", "distance"=> 550},
            {"id"=> 3, "car_id"=> 2, "start_date"=> "2017-12-8", "end_date"=> "2017-12-10", "distance"=> 150}
          ]
        }
      }
      let(:output){
        {
          rentals: [
            {
              id: 1,
              price: 7000
            },
            {
              id: 2,
              price: 15500
            },
            {
              id: 3,
              price: 11250
            }
          ]
        }
      }

      it 'calculates expected output' do
        result = Drivy.process(input)
        expect(result).to eq(output)
      end

      describe 'when no rentals are given' do

      end
    end

  end
end
