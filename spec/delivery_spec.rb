# DeliveryQuery
RSpec.describe Delivery::DeliveryQuery do
  before(:all) do
    @dc = Delivery::DeliveryClient.new('2695019d-6404-00c1-fea5-e0f187569329')
  end

  describe '.items' do
    it 'returns DeliveryQuery' do
      expect(@dc.items).to be_a Delivery::DeliveryQuery
    end
  end

  describe '.provide_url' do
    it 'returns a String' do
      expect(@dc.items.provide_url).to be_a String
    end
  end
end

# DeliveryClient
RSpec.describe Delivery::DeliveryClient do
  before(:all) do
    @dc = Delivery::DeliveryClient.new('2695019d-6404-00c1-fea5-e0f187569329')
  end

  describe '.items' do
    it 'return 30 items' do
      @dc.items.execute do |response|
        expect(response.items.length).to eq(30)
      end
    end
  end

  describe '.items with .gt filter' do
    it 'returns 4 items' do
      q = @dc.items('elements.price'.gt 20)
      q.execute do |response|
        expect(response.items.length).to eq(4)
      end
    end
  end

  describe '.items with multiple filters' do
    it 'returns 2 items' do
      q = @dc.items [
        ('elements.price'.gt 20),
        ('system.type'.eq 'grinder')
      ]
      q.execute do |response|
        expect(response.items.length).to eq(2)
      end
    end
  end
end

# QueryParameters
RSpec.describe Delivery::QueryParameters::ParameterBase do
  before(:all) do
    @dc = Delivery::DeliveryClient.new('2695019d-6404-00c1-fea5-e0f187569329')
  end

  describe '<string>.gt' do
    it 'returns a Filter' do
      expect('system.codename'.gt(5)).to be_a Delivery::QueryParameters::Filter
    end
  end

  describe 'testing area' do
    it 'works' do
      puts @dc.items('system.type'.eq 'coffee')
      .depth(0)
      .limit(5)
      .elements(%W[price product_name])
      .provide_url
      expect(true).to be true
    end
  end
end
