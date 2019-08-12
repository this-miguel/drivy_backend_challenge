
RSpec.describe 'main' do
  describe 'running' do
    it 'generates an output file' do
      File.delete('../data/output.json') if File.exist?('../data/output.json')
      load '../main.rb'
      expect(File.exist?('../data/output.json')).to eq true
    end
  end
end
