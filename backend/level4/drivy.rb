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
          rental_days = rental_days(rental['start_date'], rental['end_date'])
          price = calculate_price(rental, cars[rental['car_id']], rental_days)
          commission = (price * 0.3).round
          insurance, assistance, drivy = divide_commission(commission, rental_days)
          owner_gains = (price - commission)

          {
            id: rental['id'],
            actions: [
              action('driver','debit', price),
              action('owner','credit', owner_gains),
              action('insurance','credit', insurance),
              action('assistance','credit', assistance),
              action('drivy','credit', drivy),
            ]
          }
        end
      }
    end

    def action(actor, type, amount)
      {
        who: actor,
        type: type,
        amount: amount
      }
    end

    def calculate_price(rental, car, rental_days)
      price_per_day = car['price_per_day']
      time_price = time_price(rental_days, price_per_day)
      distance_price = rental['distance'] * car['price_per_km']
      time_price + distance_price
    end

    def rental_days(start_date, end_date)
      (Date.parse(start_date)..Date.parse(end_date)).count
    end

    def time_price(days, price_per_day)
      (1..days).inject(0) do |sum, day_number|
        case day_number
        when 1
          sum += price_per_day
        when 2..4
          sum += price_per_day * 0.9
        when 5..10
          sum += price_per_day * 0.7
        when 11..Float::INFINITY
          sum += price_per_day * 0.5
        end
      end.round
    end

    def divide_commission(commission, rental_days)
      insurance = commission / 2
      assistance = 100 * rental_days
      drivy = commission - (insurance + assistance)
      [insurance, assistance, drivy]
    end

  end
end