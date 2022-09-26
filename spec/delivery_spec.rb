PROJECT_ID = 'DummyProjectId'.freeze
SECURE_KEY = 'DummySecureApiKey'.freeze

# DeliveryQuery
RSpec.describe Kontent::Ai::Delivery::DeliveryQuery do
  before(:all) do
    @dc = Kontent::Ai::Delivery::DeliveryClient.new project_id: PROJECT_ID,
                                                         secure_key: SECURE_KEY
  end

  describe '.items' do
    it 'returns DeliveryQuery' do
      expect(@dc.items).to be_a Kontent::Ai::Delivery::DeliveryQuery
    end
  end

  describe '.execute' do
    it 'returns a ResponseBase' do
      expect(@dc.items.execute).to be_a Kontent::Ai::Delivery::Responses::ResponseBase
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
RSpec.describe Kontent::Ai::Delivery::Builders::UrlBuilder do
  before(:all) do
    @dc = Kontent::Ai::Delivery::DeliveryClient.new project_id: PROJECT_ID
  end

  describe '.provide_url' do
    it 'returns String' do
      expect(Kontent::Ai::Delivery::Builders::UrlBuilder.provide_url(@dc.items)).to be_a String
    end
  end
end

# ContentItem
RSpec.describe Kontent::Ai::Delivery::ContentItem do
  before(:all) do
    @dc = Kontent::Ai::Delivery::DeliveryClient.new project_id: PROJECT_ID,
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

  describe '.workflow_step' do
    it 'returns the item step' do
      @dc.items.execute do |response|
        expect(response.items.first.system.workflow_step).to eq('published')
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
          expect(l).to be_a Kontent::Ai::Delivery::ContentItem
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
RSpec.describe Kontent::Ai::Delivery::DeliveryClient do
  before(:all) do
    @dc = Kontent::Ai::Delivery::DeliveryClient.new project_id: PROJECT_ID,
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
        expect(response.taxonomies[0]).to be_a Kontent::Ai::Delivery::TaxonomyGroup
      end
    end

    it 'contains terms and system attributes' do
      @dc.taxonomies.execute do |response|
        expect(response.taxonomies[0].system.codename).to eql('manufacturer')
        expect(response.taxonomies[0].terms[0].codename).to eql('aerobie')
      end
    end
  end

  describe '.taxonomy' do
    it 'returns a DeliveryTaxonomyResponse' do
      @dc.taxonomy('manufacturer').execute do |response|
        expect(response).to be_a Kontent::Ai::Delivery::Responses::DeliveryTaxonomyResponse
      end
    end

    it 'contains system attributes and terms' do
      @dc.taxonomy('manufacturer').execute do |response|
        expect(response.taxonomy.system.codename).to eq('manufacturer')
        expect(response.taxonomy.terms[0].codename).to eq('aerobie')
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
      insecure = Kontent::Ai::Delivery::DeliveryClient.new project_id: PROJECT_ID

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
      url = Kontent::Ai::Delivery::Builders::UrlBuilder.provide_url(q)
      expect(url).not_to include *%w[depth skip limit]
    end

    it 'returns a DeliveryItemsFeedResponse' do
      response = @dc.items_feed.execute
      expect(response).to be_a Kontent::Ai::Delivery::Responses::DeliveryItemsFeedResponse
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

    it 'contains system and elements attributes' do
      @dc.types.execute do |response|
        expect(response.types[0].system.codename).to eq('about_us')
        expect(response.types[0].elements.url_pattern.type).to eq('url_slug')
      end
    end
  end

  describe '.type' do
    it 'returns a DeliveryTypeResponse' do
      @dc.type('brewer').execute do |response|
        expect(response).to be_a Kontent::Ai::Delivery::Responses::DeliveryTypeResponse
      end
    end

    it 'contains system and elements attributes' do
      @dc.type('brewer').execute do |response|
        expect(response.type.system.codename).to eq('brewer')
        expect(response.type.elements.product_name.type).to eq('text')
      end
    end
  end
end

# QueryParameters
RSpec.describe Kontent::Ai::Delivery::QueryParameters::ParameterBase do
  before(:all) do
    @dc = Kontent::Ai::Delivery::DeliveryClient.new project_id: PROJECT_ID,
                                                         secure_key: SECURE_KEY
  end

  describe '<string>.gt' do
    it 'returns a Filter' do
      expect('system.codename'.gt(5)).to be_a Kontent::Ai::Delivery::QueryParameters::Filter
    end
  end

  describe '<string>.empty' do
    it 'parameter contains no equal sign' do
      url = @dc.items(
        'elements.author'.empty
      ).provide_url
      params = url.split('?')[1]
      expect(params).to eq 'elements.author%5Bempty%5D'
    end
  end

  describe '<string>.not_in' do
    it 'evaluates an array of values' do
      url = @dc.items(
        'elements.author'.not_in %w[mberry ericd anthonym]
      ).provide_url
      params = url.split('?')[1]
      expect(params).to eq 'elements.author%5Bnin%5D=mberry%2Cericd%2Canthonym'
    end
  end

  describe '<string>.range' do
    it 'provides query parameter' do
      url = @dc.items(
        'elements.price'.range [10, 20.5]
      ).provide_url
      params = url.split('?')[1]
      expect(params).to eq 'elements.price%5Brange%5D=10%2C20.5'
    end
  end
end

# ContentLinkResolver
RSpec.describe Kontent::Ai::Delivery::Resolvers::ContentLinkResolver do
  before(:all) do
    @dc = Kontent::Ai::Delivery::DeliveryClient.new project_id: PROJECT_ID,
                                                         secure_key: SECURE_KEY
  end

  describe 'get_string' do
    it 'resolves links' do
      lambda_resolver = Kontent::Ai::Delivery::Resolvers::ContentLinkResolver.new(lambda do |link|
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
  class MyResolver < Kontent::Ai::Delivery::Resolvers::ContentLinkResolver
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
RSpec.describe Kontent::Ai::Delivery::Resolvers::InlineContentItemResolver do
  before(:all) do
    lambda_resolver = Kontent::Ai::Delivery::Resolvers::InlineContentItemResolver.new(lambda do |item|
      return "<h1>#{item.elements.zip_code.value}</h1>" if item.system.type.eql? 'cafe'
      return "<div>$#{item.elements.price.value}</div>" if item.system.type.eql? 'brewer'
    end)
    @dc = Kontent::Ai::Delivery::DeliveryClient.new project_id: PROJECT_ID,
                                                         secure_key: SECURE_KEY,
                                                         inline_content_item_resolver: lambda_resolver
  end

  describe 'get_string' do
    it 'resolves inline items' do
      # An inline item was manually added to this item from default project
      @dc.item('where_does_coffee_come_from_').execute do |response|
        expect(response.item.get_string('body_copy')).to include '<h1>SW3 5UR</h1>'
      end
    end
  end

  # Example of creating an item resolver in a class instead of lambda expression
  class MyResolver2 < Kontent::Ai::Delivery::Resolvers::InlineContentItemResolver
    def resolve_item(item)
      return "<h1>#{item.elements.zip_code.value}</h1>" if item.system.type.eql? 'cafe'
      return "<div>$#{item.elements.price.value}</div>" if item.system.type.eql? 'brewer'
    end
  end
end

# ImageTransformationBuilder
RSpec.describe Kontent::Ai::Delivery::Builders::ImageTransformationBuilder do
  before(:all) do
    @dc = Kontent::Ai::Delivery::DeliveryClient.new project_id: PROJECT_ID,
                                                         secure_key: SECURE_KEY
  end

  describe 'with_width' do
    it 'adds width parameter' do
      @dc.item('where_does_coffee_come_from_').execute do |response|
        url = response.item.get_assets('teaser_image').first.url
        url = Kontent::Ai::Delivery::Builders::ImageTransformationBuilder.transform(url)
                                                                              .with_width(200)
                                                                              .url
        expect(url).to include '?w=200'
      end
    end
  end

  describe 'with_focal_point' do
    it 'throws for invalid parameters' do
      @dc.item('where_does_coffee_come_from_').execute do |response|
        url = response.item.get_assets('teaser_image').first.url
        expect {
          url = Kontent::Ai::Delivery::Builders::ImageTransformationBuilder.transform(url)
                                                                                .with_focal_point(-1, 0, 0)
                                                                                .url
      }.to raise_error(ArgumentError)
      end
    end

    it 'sets correct parameters' do
      @dc.item('where_does_coffee_come_from_').execute do |response|
        url = response.item.get_assets('teaser_image').first.url
        url = Kontent::Ai::Delivery::Builders::ImageTransformationBuilder.transform(url)
                                                                              .with_focal_point(0.2, 0.3, 1.5)
                                                                              .url
        params = url.split('?')[1]
        expect(params).to eq 'fp-x=0.2&fp-y=0.3&fp-z=1.5&fit=crop&crop=focalpoint'
      end
    end
  end

  describe 'with_rect' do
    it 'removes focal point' do
      @dc.item('where_does_coffee_come_from_').execute do |response|
        url = response.item.get_assets('teaser_image').first.url
        url = Kontent::Ai::Delivery::Builders::ImageTransformationBuilder.transform(url)
                                                                              .with_focal_point(0.2, 0.3, 1.5)
                                                                              .with_rect(5, 6, 7, 8)
                                                                              .url
        params = url.split('?')[1]
        expect(params).to eq 'rect=5%2C6%2C7%2C8'
      end
    end
  end

  describe 'with_lossless' do
    it 'sets WEBP format' do
      @dc.item('where_does_coffee_come_from_').execute do |response|
        url = response.item.get_assets('teaser_image').first.url
        url = Kontent::Ai::Delivery::Builders::ImageTransformationBuilder.transform(url)
                                                                              .with_lossless(1)
                                                                              .url
        params = url.split('?')[1]
        expect(params).to eq 'lossless=1&fm=webp'
      end
    end
  end

  describe 'multiple parameters' do
    it 'adds multiple parameters' do
      @dc.item('where_does_coffee_come_from_').execute do |response|
        png = Kontent::Ai::Delivery::Builders::ImageTransformationBuilder::FORMAT_PNG
        url = response.item.get_assets('teaser_image').first.url
        url = Kontent::Ai::Delivery::Builders::ImageTransformationBuilder.transform(url)
                                                                              .with_height(200)
                                                                              .with_output_format(png)
                                                                              .with_auto_format_selection(1)
                                                                              .url
        params = url.split('?')[1]
        expect(params).to eq 'h=200&fm=png&auto=format'
      end
    end
  end
end

# Languages
RSpec.describe Kontent::Ai::Delivery::Language do
  before(:all) do
    @dc = Kontent::Ai::Delivery::DeliveryClient.new project_id: PROJECT_ID,
                                                         secure_key: SECURE_KEY
  end

  describe '.languages' do
    it 'returns a DeliveryLanguageListingResponse' do
      @dc.languages.execute do |response|
        expect(response).to be_a Kontent::Ai::Delivery::Responses::DeliveryLanguageListingResponse
      end
    end

    it 'contains system attributes' do
      @dc.languages.execute do |response|
        expect(response.languages[0].system.codename).to eq('en-US')
      end
    end
  end
end
