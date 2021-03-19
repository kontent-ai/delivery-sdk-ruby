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

  describe '.custom_headers' do
    it 'adds custom headers' do
      custom_headers = { 'X-KC-SOURCE' => 'test_gem 1.0.0' }

      expect(@dc.items.custom_headers(custom_headers).send(:headers)).to include custom_headers
    end

    it 'does not override original headers' do
      custom_headers = { 'X-KC-SDKID' => 'test' }

      expect(@dc.items.custom_headers(custom_headers).send(:headers)).not_to include custom_headers
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

  describe '.collections' do
    it 'returns the item collection' do
      @dc.items.execute do |response|
        expect(response.items.first.system.collection).to eq('default')
      end
    end
  end

  describe '.include_total_count' do
    it 'adds pagination attribute' do
      @dc.items.include_total_count.execute do |response|
        expect(response.pagination.total_count).to be_a Integer
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

  describe 'richtext element' do
    it 'handle complex tables content' do
      path = Pathname
             .new(File.dirname(__FILE__) + '/lib/delivery/tests/generic/items/rich_text_complex_tables.json')
             .relative_path_from(Pathname.new(File.dirname(__FILE__)))
      text = File.read(path)
      json = JSON.parse(text)
      actual = json['item']['elements']['rich_text']['value']
      @dc.item('rich_text_complex_tables').execute do |response|
        expect(response.item.elements.rich_text.value).to eq actual
      end
    end

    it 'handles empty value' do
      @dc.item('empty_rich_text').execute do |response|
        expect(response.item.elements.body_copy.value).to eq('')
        expect(response.item.get_string 'body_copy').to eq('')
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

  describe 'retry policy' do
    it 'delays for at least 6 seconds' do
      start = (Time.now.to_f * 1000).to_i
      @dc.item('429').execute do |response|
        finish = (Time.now.to_f * 1000).to_i
        secs = (finish - start) / 1000

        expect(response.http_code).to be 429
        expect(secs).to be > 6
      end
     end
  end

  describe '.taxonomies' do
    it 'returns 5 groups' do
      @dc.taxonomies.execute do |response|
        expect(response.taxonomies.length).to eql(5)
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
    it 'return 30 items' do
      @dc.items.execute do |response|
        expect(response.items.length).to eq(30)
      end
    end
  end

  describe '.items_feed' do
    it 'doesnt support certain parameters' do
      q = @dc.items_feed.depth(5).skip(5).limit(5)
      url = Kentico::Kontent::Delivery::Builders::UrlBuilder.provide_url(q)
      expect(url).not_to include *%w[depth skip limit]
    end
    it 'returns a DeliveryItemsFeedResponse' do
      response = @dc.items_feed.execute
      expect(response).to be_a Kentico::Kontent::Delivery::Responses::DeliveryItemsFeedResponse
    end
    it '.next_result returns more items' do
      r1 = @dc.items_feed.execute
      r2 = r1.next_result if r1.more_results?
      r3 = r2.next_result if r2.more_results?
      expect(r1.items.length).to eq(1)
      expect(r2.items.length).to eq(2)
      expect(r3.items.length).to eq(3)
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
          expect(response.item.get_string('body_copy')).not_to include 'href=\"\"'
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
        expect(response.item.get_string('body_copy')).not_to include 'data-rel=\"link\"'
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
