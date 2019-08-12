require 'date'

class Drivy
  class << self
    attr_accessor :cars, :rentals, :options

    def process(input)
      check(input)
      self.cars = input['cars'].inject({}) do |memo, car|
        memo[car['id']] = car
        memo
      end
      self.rentals = input['rentals']
      self.options = input['options']
      calculate_each_rental
    end

    def check(input)
      ['cars', 'options', 'rentals'].each do |key|
        unless input[key].is_a?(Array)
          raise ArgumentError, "\"input['#{key}']\" was not an Array. input['#{key}'] => #{input[key].inspect}."
        end
      end
    end

    def check_car(car, rental)
      if car.nil?
        raise ArgumentError, "rental['car_id'] => #{rental['car_id'].inspect} resulted in nil while looking up in Drivy.cars. " +
          "Seems like that id not present in 'input['cars']'"
      end
    end

    def calculate_each_rental
      {
        rentals: rentals.map do |rental|
          rental_options = options_for_rental_id(rental['id'], options)
          car = cars[rental['car_id']]
          check_car(car, rental)

          amounts = actors_amounts(rental, car, rental_options)

          {
            id: rental['id'],
            options: rental_options,
            actions: [
              action('driver','debit', amounts[:driver_pays]),
              action('owner','credit', amounts[:owner_gains]),
              action('insurance','credit', amounts[:insurance]),
              action('assistance','credit', amounts[:assistance]),
              action('drivy','credit', amounts[:drivy_gains]),
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

    def actors_amounts(rental, car, rental_options)
      rental_days = rental_days(rental['start_date'], rental['end_date'])

      options_total, baby_seat, gps, additional_insurance =  options_price(rental_options, rental_days)
      price_without_options = calculate_price(rental, car, rental_days)
      commission = (price_without_options * 0.3).round
      insurance, assistance, drivy_commision = divide_commission(commission, rental_days)
      owner_gains = (price_without_options - commission) + baby_seat + gps
      drivy_gains = drivy_commision + additional_insurance
      driver_pays = price_without_options + options_total
      {
        driver_pays: driver_pays,
        owner_gains: owner_gains,
        insurance: insurance,
        assistance: assistance,
        drivy_gains: drivy_gains,
        drivy_commision: drivy_commision,
        price_without_options: price_without_options
      }
    end

    def calculate_price(rental, car, rental_days)
      price_per_day = car['price_per_day']
      time_price = time_price(rental_days, price_per_day)
      distance_price = rental['distance'] * car['price_per_km']
      time_price + distance_price
    end

    def rental_days(start_date, end_date)
      beginning = Date.parse(start_date)
      ending = Date.parse(end_date)

      unless ending >= beginning
        raise ArgumentError, "beginning date must be greater or equal to ending date. " +
        "begining date was parsed from: '#{start_date}', ending date was parsed from '#{end_date}'"
      end

      (beginning..ending).count
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

    def options_for_rental_id(rental_id, options)
      options.select do |option|
        option['rental_id'] == rental_id
      end.map { |option| option['type'] }
    end

    def options_price(options, days)
      baby_seat = 0
      gps = 0
      additional_insurance = 0
      total = options.inject(0) do |sum, option|
        case option
        when 'baby_seat' # 2€/day
          baby_seat = 200 * days
          sum += baby_seat
        when 'gps' # 5€/day
          gps = 500 * days
          sum += gps
        when 'additional_insurance' # 10€/day
          additional_insurance = 1_000 * days
          sum += additional_insurance
        end
        sum
      end
      [total, baby_seat, gps, additional_insurance]
    end

  end
end