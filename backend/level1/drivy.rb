require 'date'

class Drivy
  class << self
    attr_accessor :cars, :rentals

    def process(input)
      self.cars = input['cars'].inject({}) do |memo, car|
        memo[car['id']] = car
        memo
      end
      self.rentals = input['rentals']
      calculate_each_rental
    end

    def calculate_each_rental
      {
        rentals: rentals.map do |rental|
          {
              id: rental['id'],
              price: calculate_price(rental)
          }
        end
      }
    end

    def calculate_price(rental)
      car = cars[rental['car_id']]
      rental_days = rental_days(rental['start_date'], rental['end_date'])
      time_price = time_price(rental_days, car['price_per_day'])
      distance_price = distance_price(rental['distance'],car['price_per_km'])
      time_price + distance_price
    end

    def rental_days(start_date, end_date)
      (Date.parse(start_date)..Date.parse(end_date)).count
    end

    def time_price(days, price_per_day)
      days * price_per_day
    end

    def distance_price(kilometers, price_per_kilometres)
      kilometers * price_per_kilometres
    end

  end
end