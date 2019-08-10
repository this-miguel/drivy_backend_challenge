require 'json'

# read input file
input_path = File.expand_path('data/input.json', File.dirname(__FILE__))
input_file =  File.open(input_path, 'r')
input_data = JSON.load(input_file)

class Drivy
  def self.process(input)
    {hola: 'hola'}
  end
end

# write output file
output_data = Drivy.process(input_data)
output_path = File.expand_path('data/output.json', File.dirname(__FILE__))
output_file = File.open(output_path, 'w')
JSON.dump(output_data, output_file)
output_file.close
