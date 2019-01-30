PROJECT_ID = '<redacted>'.freeze
PREVIEW_KEY = '<redacted>'.freeze
SECURE_KEY = '<redacted>'.freeze

# DeliveryQuery
RSpec.describe Delivery::DeliveryQuery do
  before(:all) do
    @dc = Delivery::DeliveryClient.new project_id: PROJECT_ID
  end

  describe '.items' do
    it 'returns DeliveryQuery' do
      expect(@dc.items).to be_a Delivery::DeliveryQuery
    end
  end
end

# UrlProvider
RSpec.describe Delivery::UrlProvider do
  before(:all) do
    @dc = Delivery::DeliveryClient.new project_id: PROJECT_ID
  end

  describe '.provide_url' do
    it 'returns String' do
      expect(Delivery::UrlProvider.provide_url(@dc.items)).to be_a String
    end
  end
end

# ContentItem
RSpec.describe Delivery::ContentItem do
  before(:all) do
    @dc = Delivery::DeliveryClient.new project_id: PROJECT_ID,
                                       secure_key: SECURE_KEY
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
    @dc = Delivery::DeliveryClient.new project_id: PROJECT_ID,
                                       secure_key: SECURE_KEY,
                                       preview_key: PREVIEW_KEY
  end

  describe 'secure_key' do
    it 'results in 200 status' do
      insecure = Delivery::DeliveryClient.new project_id: PROJECT_ID
      insecure.items.execute do |response|
        @status1 = response.http_code
      end

      @dc.items.execute do |response|
        expect(@status1).to eql(401)
        expect(response.http_code).to eql(200)
      end
    end
  end

  describe 'ctor' do
    it 'enables preview' do
      expect(@dc.use_preview).to be true
    end
  end

  describe '.items' do
    it 'return 46 items' do
      @dc.items.execute do |response|
        expect(response.items.length).to eq(46)
      end
    end
  end

  describe '.types' do
    it 'returns 13 types' do
      @dc.types.execute do |response|
        expect(response.types.length).to eq(13)
      end
    end
  end
end

# Filters
RSpec.describe Delivery::QueryParameters::Filter do
  before(:all) do
    @dc = Delivery::DeliveryClient.new project_id: PROJECT_ID,
                                       secure_key: SECURE_KEY
  end

  describe '.items with .gt filter' do
    it 'returns 4 items' do
      q = @dc.items('elements.price'.gt(20))
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
    @dc = Delivery::DeliveryClient.new project_id: PROJECT_ID,
                                       secure_key: SECURE_KEY
  end

  describe '<string>.gt' do
    it 'returns a Filter' do
      expect('system.codename'.gt(5)).to be_a Delivery::QueryParameters::Filter
    end
  end
end

# LinkResolver
RSpec.describe Delivery::Resolvers::ContentLinkResolver do
  before(:all) do
    @dc = Delivery::DeliveryClient.new project_id: PROJECT_ID,
                                       secure_key: SECURE_KEY
  end

  describe 'linkresolver' do
    it 'resolves links' do
      lambda_resolver = Delivery::Resolvers::ContentLinkResolver.new(lambda do |link|
        return "/coffees/#{link.url_slug}" if link.type == 'coffee'
        return "/brewers/#{link.url_slug}" if link.type == 'brewer'
      end)

      @dc.item('coffee_processing_techniques')
         .with_link_resolver(lambda_resolver)
         .depth(0).execute do |response|
        expect(response.item.get_string('body_copy')).not_to eql(response.item.elements.body_copy.value)
      end
    end
  end

  # Example of creating a link resolver in a class instead of lambda expression
  class MyResolver < Delivery::Resolvers::ContentLinkResolver
    def resolve_link(link)
      return "/coffees/#{link.url_slug}" if link.type == 'coffee'
      return "/brewers/#{link.url_slug}" if link.type == 'brewer'
    end
  end
end
