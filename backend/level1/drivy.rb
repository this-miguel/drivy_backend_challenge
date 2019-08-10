class Drivy
  class << self
    attr_accessor :cars, :rentals

    def process(input)
      self.cars = input['cars'].inject({}) do |memo, car|
        memo[car[:id]] = car
        memo
      end
      self.rentals = input['rentals']
      calculate_each_rental
    end

    def calculate_each_rental
      rentals.each do |rental|
        calculate_price(rental)
      end
    end

    def calculate_price(rental)
      car = cars[rental['car_id']]

    end
  end
end