# DeliveryQuery
RSpec.describe Delivery::DeliveryQuery do
  before(:all) do
    @dc = Delivery::DeliveryClient.new project_id: '2695019d-6404-00c1-fea5-e0f187569329'
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

# ContentItem
RSpec.describe Delivery::DeliveryClient do
  before(:all) do
    @dc = Delivery::DeliveryClient.new project_id: '2695019d-6404-00c1-fea5-e0f187569329'
  end

  describe '.pagination' do
    it 'contains data' do
      @dc.items
          .skip(0)
          .limit(5)
          .execute do |response|
            expect(response.pagination.next_page).to be_a String
          end
    end
  end
end

# DeliveryClient
RSpec.describe Delivery::DeliveryClient do
  before(:all) do
    @dc = Delivery::DeliveryClient.new project_id: '2695019d-6404-00c1-fea5-e0f187569329',
                                       preview_key: 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJqdGkiOiI2YTkxZmY5ZGMwZGE0YmY4YjAzNjQyZTcyMjhlNzkwNSIsImlhdCI6IjE1NDM1ODUzNzkiLCJleHAiOiIxODg5MTg1Mzc5IiwicHJvamVjdF9pZCI6IjI2OTUwMTlkNjQwNDAwYzFmZWE1ZTBmMTg3NTY5MzI5IiwidmVyIjoiMS4wLjAiLCJhdWQiOiJwcmV2aWV3LmRlbGl2ZXIua2VudGljb2Nsb3VkLmNvbSJ9.4ET7kyRyhBN293JaQ1ZUGFMqSRHfZJmVgeh6blnin0Q'
  end

  describe 'ctor' do
    it 'enables preview' do
      expect(@dc.use_preview).to be true
    end
  end

  describe '.items' do
    it 'return 30 items' do
      @dc.items.execute do |response|
        expect(response.items.length).to eq(46)
      end
    end
  end

  describe '.items with .gt filter' do
    it 'returns 4 items' do
      q = @dc.items('elements.price'.gt 20)
      q.execute do |response|
        expect(response.items.length).to eq(8)
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
        expect(response.items.length).to eq(3)
      end
    end
  end
end

# QueryParameters
RSpec.describe Delivery::QueryParameters::ParameterBase do
  before(:all) do
    @dc = Delivery::DeliveryClient.new project_id: '2695019d-6404-00c1-fea5-e0f187569329'
  end

  describe '<string>.gt' do
    it 'returns a Filter' do
      expect('system.codename'.gt(5)).to be_a Delivery::QueryParameters::Filter
    end
  end
end
