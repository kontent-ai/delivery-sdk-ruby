require 'dotenv/load'

PROJECT_ID = ENV['PROJECT_ID']
PREVIEW_KEY = ENV['PREVIEW_KEY']
SECURE_KEY = ENV['SECURE_KEY']

# DeliveryQuery
RSpec.describe Kentico::Kontent::Delivery::DeliveryQuery do
  before(:all) do
    @dc = Kentico::Kontent::Delivery::DeliveryClient.new project_id: PROJECT_ID,
                                                     secure_key: SECURE_KEY
  end

  describe '.items' do
    it 'returns DeliveryQuery' do
      expect(@dc.items).to be_a Kentico::Kontent::Delivery::DeliveryQuery
    end
  end

  describe '.execute' do
    it 'returns a ResponseBase' do
      expect(@dc.items.execute).to be_a Kentico::Kontent::Delivery::Responses::ResponseBase
    end
  end
end

# UrlBuilder
RSpec.describe Kentico::Kontent::Delivery::Builders::UrlBuilder do
  before(:all) do
    @dc = Kentico::Kontent::Delivery::DeliveryClient.new project_id: PROJECT_ID
  end

  describe '.provide_url' do
    it 'returns String' do
      expect(Kentico::Kontent::Delivery::Builders::UrlBuilder.provide_url(@dc.items)).to be_a String
    end
  end
end

# ContentItem
RSpec.describe Kentico::Kontent::Delivery::ContentItem do
  before(:all) do
    @dc = Kentico::Kontent::Delivery::DeliveryClient.new project_id: PROJECT_ID,
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

  describe '.get_asset' do
    it 'returns a URL' do
      @dc.item('aeropress_filters').execute do |response|
        expect(response.item.get_assets('image').first.url).to be_a String
      end
    end
  end

  describe '.get_links' do
    it '.gets 3 ContentItems' do
      @dc.item('about_us').execute do |response|
        links = response.item.get_links 'facts'
        expect(links.length).to eq(3)
        links.each do |l|
          expect(l).to be_a Kentico::Kontent::Delivery::ContentItem
          expect(l.system.codename).not_to be_nil
        end
      end
    end
  end
end

# DeliveryClient
RSpec.describe Kentico::Kontent::Delivery::DeliveryClient do
  before(:all) do
    @dc = Kentico::Kontent::Delivery::DeliveryClient.new project_id: PROJECT_ID,
                                                     secure_key: SECURE_KEY
  end

  describe '.taxonomies' do
    it 'returns 4 groups' do
      @dc.taxonomies.execute do |response|
        expect(response.taxonomies.length).to eql(4)
        expect(response.taxonomies[0]).to be_a Kentico::Kontent::Delivery::TaxonomyGroup
      end
    end
  end

  describe '.element' do
    it 'returns a content type element' do
      @dc.element('brewer', 'product_status').execute do |response|
        expect(response.element.type).to eq('taxonomy')
      end
    end
  end

  describe 'secure_key' do
    it 'results in 200 status' do
      insecure = Kentico::Kontent::Delivery::DeliveryClient.new project_id: PROJECT_ID

      expect(insecure.items.execute.http_code).to eql(401)
      expect(@dc.items.execute.http_code).to eql(200)
    end
  end

  describe '.items' do
    it 'return 31 items' do
      @dc.items.execute do |response|
        expect(response.items.length).to eq(31)
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
RSpec.describe Kentico::Kontent::Delivery::QueryParameters::Filter do
  before(:all) do
    @dc = Kentico::Kontent::Delivery::DeliveryClient.new project_id: PROJECT_ID,
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
RSpec.describe Kentico::Kontent::Delivery::QueryParameters::ParameterBase do
  before(:all) do
    @dc = Kentico::Kontent::Delivery::DeliveryClient.new project_id: PROJECT_ID,
                                                     secure_key: SECURE_KEY
  end

  describe '<string>.gt' do
    it 'returns a Filter' do
      expect('system.codename'.gt(5)).to be_a Kentico::Kontent::Delivery::QueryParameters::Filter
    end
  end
end

# ContentLinkResolver
RSpec.describe Kentico::Kontent::Delivery::Resolvers::ContentLinkResolver do
  before(:all) do
    @dc = Kentico::Kontent::Delivery::DeliveryClient.new project_id: PROJECT_ID,
                                                     secure_key: SECURE_KEY
  end

  describe 'get_string' do
    it 'resolves links' do
      lambda_resolver = Kentico::Kontent::Delivery::Resolvers::ContentLinkResolver.new(lambda do |link|
        return "/coffees/#{link.url_slug}" if link.type.eql? 'coffee'
        return "/brewers/#{link.url_slug}" if link.type.eql? 'brewer'
      end, lambda do |id|
        return "/notfound?id=#{id}"
      end)

      @dc.item('coffee_processing_techniques')
         .with_link_resolver(lambda_resolver)
         .execute do |response|
           expect(response.item.get_string('body_copy')).not_to eql(response.item.elements.body_copy.value)
         end
    end
  end

  # Example of creating a link resolver in a class instead of lambda expression
  class MyResolver < Kentico::Kontent::Delivery::Resolvers::ContentLinkResolver
    def resolve_link(link)
      return "/coffees/#{link.url_slug}" if link.type.eql? 'coffee'
      return "/brewers/#{link.url_slug}" if link.type.eql? 'brewer'
    end

    def resolve_404(id)
      "/notfound?id=#{id}"
    end
  end
end

# InlineContentItemResolver
RSpec.describe Kentico::Kontent::Delivery::Resolvers::InlineContentItemResolver do
  before(:all) do
    lambda_resolver = Kentico::Kontent::Delivery::Resolvers::InlineContentItemResolver.new(lambda do |item|
      return "<h1>#{item.elements.zip_code.value}</h1>" if item.system.type.eql? 'cafe'
      return "<div>$#{item.elements.price.value}</div>" if item.system.type.eql? 'brewer'
    end)
    @dc = Kentico::Kontent::Delivery::DeliveryClient.new project_id: PROJECT_ID,
                                                     secure_key: SECURE_KEY,
                                                     inline_content_item_resolver: lambda_resolver
  end

  describe 'get_string' do
    it 'resolves inline items' do
      # A content link was manually added to this item
      @dc.item('where_does_coffee_come_from_').execute do |response|
        expect(response.item.get_string('body_copy')).not_to eql(response.item.elements.body_copy.value)
      end
    end
  end

  # Example of creating an item resolver in a class instead of lambda expression
  class MyResolver2 < Kentico::Kontent::Delivery::Resolvers::InlineContentItemResolver
    def resolve_item(item)
      return "<h1>#{item.elements.zip_code.value}</h1>" if item.system.type.eql? 'cafe'
      return "<div>$#{item.elements.price.value}</div>" if item.system.type.eql? 'brewer'
    end
  end
end
