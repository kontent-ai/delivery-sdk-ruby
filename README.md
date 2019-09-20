[![Build Status](https://api.travis-ci.com/Kentico/kontent-delivery-sdk-ruby.svg?branch=master)](https://travis-ci.com/Kentico/kontent-delivery-sdk-ruby)
[![Join the chat at https://kentico-community.slack.com](https://img.shields.io/badge/join-slack-E6186D.svg)](https://kentico-community.slack.com)
[![Stack Overflow](https://img.shields.io/badge/Stack%20Overflow-ASK%20NOW-FE7A16.svg?logo=stackoverflow&logoColor=white)](https://stackoverflow.com/tags/kentico-cloud)
 [![Version](https://img.shields.io/gem/v/kontent-delivery-sdk-ruby.svg?style=flat)](https://rubygems.org/gems/kontent-delivery-sdk-ruby)
 [![Maintainability](https://api.codeclimate.com/v1/badges/b2e3fae28a2b2601d815/maintainability)](https://codeclimate.com/github/Kentico/kontent-delivery-sdk-ruby/maintainability)
 [![Test coverage](https://codeclimate.com/github/Kentico/kontent-delivery-sdk-ruby/test_coverage)](https://api.codeclimate.com/v1/badges/b2e3fae28a2b2601d815/test_coverage)

# Delivery Ruby SDK

![Banner](https://github.com/Kentico/kontent-delivery-sdk-ruby/blob/master/banner.png)

The Delivery Ruby SDK can be used in Ruby/Rails projects to retrieve content from Kentico Cloud. This is a community project and not an official Kentico SDK. If you find a bug in the SDK or have a feature request, please submit a GitHub issue.

See [How to setup a development environment on Windows](https://github.com/Kentico/kontent-delivery-sdk-ruby/wiki/How-to-setup-development-environment-on-Windows) for local development.


## Demo Rails application

This repository contains a very basic Rails application that you can run locally to see how the SDK can be used. To run the Dancing Goat demo application, clone this repository and open `/dancing_goat/app/controllers/application_controller.rb`. Add your project ID to the file here:

```ruby
class ApplicationController < ActionController::Base
  PROJECT_ID = '<your-project-id>'.freeze
```

If you don't have the sample project installed in Kentico Cloud, you can generate a new project [here](https://app.kontent.ai/sample-project-generator). Save the file, then open a terminal in the `/dancing_goat` directory and run the following commands:

```
bundle install
rails server
```

The site should be accessible at localhost:3000. You can also follow a step-by-step guide to creating a basic Rails application on the [Kentico Cloud Blog](https://kontent.ai/blog/creating-a-kentico-cloud-ruby-on-rails-application).

## Installation

To use the SDK in your own project, add the gem to your Gemfile:

```ruby
gem 'kontent-delivery-sdk-ruby'
```

Then run `bundle install`. You can also download the gem from [RubyGems.org](https://rubygems.org/gems/kontent-delivery-sdk-ruby). To use the SDK in an `.rb` file, you need to require it:

```ruby
require 'kontent-delivery-sdk-ruby'
```

## Creating a client

You will use `Kentico::Kontent::Delivery::DeliveryClient` to obtain content from Kentico Cloud. Create an instance of the client and pass your project ID:

```ruby
delivery_client = Kentico::Kontent::Delivery::DeliveryClient.new project_id: '<your-project-id>'
```

:gem: **Pro tip:** You can alias namespaces to make them shorter, e.g.

```ruby
KK = Kentico::Kontent::Delivery
delivery_client = KK::DeliveryClient.new project_id: '<your-project-id>'
```

### Previewing unpublished content

To enable [preview](https://developer.kenticocloud.com/docs/previewing-content-in-a-separate-environment "preview"), pass the Preview API Key to the constructor:

```ruby
delivery_client = Kentico::Kontent::Delivery::DeliveryClient.new project_id: '<your-project-id>',
                                                                 preview_key: '<your-preview-key>'
```

This enables preview, but you can toggle preview at any time by setting the `use_preview` attribute of DeliveryClient which is propogated to all queries created by the client, _or_ per-query by setting it's `use_preview` attribute:

```ruby
# For all queries created by client
delivery_client.use_preview = false

# Per-query
query = delivery_client.items
query.use_preview = false
query.execute do |response|
  # Do something
end
```

### Making secure requests

If you've [secured access](https://developer.kenticocloud.com/docs/securing-public-access "Securing public access") to your project, you need to provide the DeliveryClient with the primary or secondary key:

```ruby
Kentico::Kontent::Delivery::DeliveryClient.new project_id: '<your-project-id>',
                                           secure_key: '<your-secure-key>'
```

### Retry policy

By default, the SDK uses a retry policy, asking for requested content again in case of an error. The default policy retries the HTTP requests if the following status codes are returned:

* 408 - `RequestTimeout`
* 500 - `InternalServerError`
* 502 - `BadGateway`
* 503 - `ServiceUnavailable`
* 504 - `GatewayTimeout`

The default policy retries requests 5 times, totaling 6 overall attempts to retrieve content before returning a `ResponseBase` object containing the error. The consecutive attempts are delayed exponentially: 200 milliseconds, 400 milliseconds, 800 milliseconds, etc.

To disable the retry policy, you can use the `with_retry_policy` argument:

```ruby
Kentico::Kontent::Delivery::DeliveryClient.new project_id: '<your-project-id>',
                                           secure_key: '<your-secure-key>',
                                           with_retry_policy: false
```

## Listing items


Use `.item` or `.items` to create a `Kentico::Kontent::Delivery::DeliveryQuery`, then call `.execute` to perform the request.

```ruby
delivery_client.items.execute do |response|
  response.items.each do |item|
    # Do something
  end
end
```

You can also execute the query without a block and just get the response:

```ruby
response = delivery_client.items.execute
```

### Filtering

You can use [filtering](https://developer.kenticocloud.com/v1/reference#content-filtering "filtering") to retrieve particular items. The filtering methods are applied directly to a string and the available methods are:

|Method|Example|REST equivalent|
|--|--|--|
|all|`'elements.product_status'.all %w[bestseller on_sale]`|?elements.product_status[all]=bestseller,on_sale|
|any|`'elements.processing'.any %w[dry__natural_ semi_dry]`|?elements.processing[any]=dry__natural_,semi_dry|
|contains|`'elements.related_articles'.contains 'on_roasts'`|?elements.related_articles[contains]=on_roasts|
|eq|`'system.type'.eq 'grinder'`|?system.type=grinder|
|gt|`'elements.price'.gt 20`|?elements.price[gt]=20|
|gt_or_eq|`'elements.price'.gt_or_eq 20`|?elements.price[gte]=20|
|in|`'system.type'.in %w[coffee brewer]`|?system.type[in]=coffee,brewer|
|lt|`'elements.price'.lt 20`|?elements.price[lt]=20|
|lt_or_eq|`'elements.price'.lt_or_eq 20`|?elements.price[lte]=20|
|range|`'system.last_modified'.range %w[2018-02-01 2018-03-31]`|?system.last_modified[range]=2018-02-01,2018-03-31|

You can pass a single filter or multiple filters in the DeliveryClient methods. For example:

```ruby
# Single filter
delivery_client.items('elements.price'.gt 20)

# Multiple filters
delivery_client.items [
  ('elements.price'.gt 20),
  ('system.type'.eq 'grinder')
]
```

### Parameters

The `.item` and `.items` methods return a `Kentico::Kontent::Delivery::DeliveryQuery` object which you can further configure before executing. The methods you can call are:

|Method|Example|REST equivalent
|--|--|--|
|[order_by](https://developer.kenticocloud.com/v1/reference#content-ordering "order_by")|`order_by 'system.last_modified' '[desc]'`|?order=system.last_modified[desc]
|[skip](https://developer.kenticocloud.com/v1/reference#listing-response-paging "skip")|`skip 5`|?skip=5
|[limit](https://developer.kenticocloud.com/v1/reference#listing-response-paging "limit")|`limit 5`|?limit=5
|[elements](https://developer.kenticocloud.com/v1/reference#projection "elements")|`elements %w[price product_name image]`|?elements=price,product_name,image
|[depth](https://developer.kenticocloud.com/v1/reference#linked-content "depth")|`depth 0`|?depth=0
|[language](https://developer.kenticocloud.com/docs/understanding-language-fallbacks "language")|`language 'en'`|?language=en

For example:

```ruby
delivery_client.items('system.type'.eq 'coffee')
  .depth(0)
  .limit(5)
  .elements(%W[price product_name])
  .execute do |response|
    # Do something
  end
```

### Requesting the latest content

Kentico caches content using Fastly, so requests made to Kentico Cloud may not be up-to-date. In some cases, such as when reacting to [webhook](https://developer.kenticocloud.com/docs/webhooks) notifications, you might want to request the latest content from your Kentico Cloud project.

You can bypass the cache and get the latest content using `request_latest_content`

```ruby
delivery_client.items('system.type'.eq 'coffee')
  .request_latest_content
  .execute
```

### Custom URLs

When you have a URL (i.e. `next_page` for paging, for testing purposes, or if you prefer to build it on your own) and still want to leverage SDK functionality such as rich text resolving, use the .url method:

```ruby
delivery_client.items
  .url('https://deliver.kontent.ai/<your-project-id>/items?system.type=grinder')
  .execute do |response|
    # Do something
  end
```

### Responses

All responses from the `.execute` method will be/extend the `Kentico::Kontent::Delivery::Responses::ResponseBase` class which contains an `http_code` attribute and a friendly message that can be displayed by calling `.to_s`. You can check the code to determine if the request was successful:

```ruby
delivery_client.items.execute do |response|
  case response.http_code
  when 200
    # Success!
  when 401
    # Did you forget the secure key?
  else
    puts response.to_s
  end
end
```

You can also view the raw JSON response of the the query using the `.json` attribute.

For successful content item queries, you will get either `DeliveryItemResponse` for single item queries, or `DeliveryItemListingResponse` for multiple item queries. You can access the returned content item(s) at `.item` or `.items` respectively.

The `ContentItem` object gives you access to all system elements and content type elements at the `.system` and `.elements` properies. These are dynamic objects, so you can simply type the name of the element you need:

```ruby
price = response.item.elements.price.value
```

### Assets

You can use `.get_assets(code_name)` to get one or more assets from the specified element. This method will always return an array, so use `.first` to get the first asset:

```ruby
url = response.item.get_assets('teaser_image').first.url
```

### Linked items

You can get a simple array of code names by accessing the element's value:

```ruby
links = response.item.elements.facts.value
```

The `.get_links(element)` method will return an array of ContentItems instead:

```ruby
response.item.get_links('facts').each do |link|
  title = link.elements.title.value
end
```

### Pagination

The `DeliveryItemListingResponse` also contains a `pagination` attribute to access the [paging](https://developer.kenticocloud.com/v1/reference#listing-response-paging "paging") data for the Delivery query. This object contains the following attributes:

- **skip**
- **limit**
- **count**
- **next_page**

For example, to access the next page URL you can use:

```ruby
delivery_client.items
    .skip(0)
    .limit(5)
    .execute do |response|
      next_page_url = response.pagination.next_page
    end
```

You can then request the secure published content in your project. Be sure to not expose the key if the file(s) it appears in are publicly-available.

## Retrieving content types

You can use the `.type` and `.types` methods to request your content types from Kentico Cloud:

```ruby
delivery_client.types.execute do |response|
  # Do something
end
delivery_client.type('coffee').execute do |response|
  # Do something
end
```

### Responses

As with content item queries, all content type queries will return a `Kentico::Kontent::Delivery::Responses::ResponseBase` of the class `DeliveryTypeResponse` or `DeliveryTypeListingResponse` for single and multiple type queries, respectively.

For multiple type queries, you can access the array of `ContentType` objects at `.types`, and at `.type` for singe type queries. You can access information about the type(s) dynamically:

```ruby
delivery_client.type('coffee').execute do |response|
  field_type = response.type.elements.product_status.type # taxonomy
end
```
The DeliveryTypeListingResponse also contains pagination data, similar to DeliveryItemListingResponse.

## Taxonomy

Use the `.taxonomies` and `.taxonomy(code_name)` endpoints to get information about the taxonomy in your project:

```ruby
# Get all taxonomies
delivery_client.taxonomies.execute do |response|
  response.taxonomies.each do |tax|
    puts "#{tax.system.name} (#{tax.terms.length})"
  end
end

# Get terms of specific taxonomy
delivery_client.taxonomy('personas').execute do |response|
  puts response.taxonomy.terms.length
end
```

Each response will return either a single `Kentico::Kontent::Delivery::TaxonomyGroup` or an array of groups. The taxonomy group(s) are accessible at `.taxonomy` and `.taxonomies` for single and multiple queries, respectively.

The `TaxonomyGroup` object contains two attributes `.system` and `.terms` which are dynamic OStruct objects containing the same elements as a standard JSON reponse. For example, given a successful query you could access information about the first term of a group using:

```ruby
taxonomy_group.terms[0].codename
```

Note that the terms of a taxonomy group may also contain terms, for example in Dancing Goat's __Personas__ taxonomy group, which looks like this:

- Coffee expert
  - Barista
  - Cafe owner
- Coffee enthusiast
  - Coffee lover
  - Coffee blogger

To get the code name of the first term under the "Coffee expert" term, you could do this:

```ruby
delivery_client.taxonomy('personas').execute do |response|
  puts response.taxonomy.terms[0].terms[0].codename
end
```

## Retrieving content type elements

Kentico Cloud provides an [endpoint](https://developer.kenticocloud.com/v1/reference#view-a-content-type-element) for obtaining details about a specific element of a content type. In the Ruby SDK, you can use the `.element` method:

```ruby
delivery_client.element('brewer', 'product_status').execute do |response|
  puts response.element.type # taxonomy
end
```

This returns a `Kentico::Kontent::Delivery::Responses::DeliveryElementResponse` where the `element` attribute is a dynamic OStruct representation of the JSON response. This means that you can access any property of the element by simply typing the name as in the above example.

The element will always contain __codename__, __type__, and __name__, but multiple choice elements will also contain __options__ and taxonomy elements will contain __taxonomy_group__. The Ruby SDK fully supports obtaining [custom elements](https://developer.kenticocloud.com/v1/reference#custom-elements-api) using this approach and any other methods.

## Resolving links

If a rich text element contains links to other content items, you will need to generate the URLs to those items. You can do this by registering a `Kentico::Kontent::Delivery::Resolvers::ContentLinkResolver` when you instantiate the DeliveryClient. When you create a ContentLinkResolver, you must pass a method that will return the URL, and you may pass another method that will be called if the content contains a link, but the content item is not present in the response:

```ruby
link_resolver = Kentico::Kontent::Delivery::Resolvers::ContentLinkResolver.new(lambda do |link|
        # Link valid
        return "/coffees/#{link.url_slug}" if link.type.eql? 'coffee'
        return "/brewers/#{link.url_slug}" if link.type.eql? 'brewer'
      end, lambda do |id|
        # Link broken
        return "/notfound?id=#{id}"
      end)
delivery_client = Kentico::Kontent::Delivery::DeliveryClient.new project_id: '<your-project-id>',
                                                             content_link_url_resolver: link_resolver
```

You can also build the logic for your resolver in a separate class and register an instance of that class in the DeliveryClient. The class must extend `Kentico::Kontent::Delivery::Resolvers::ContentLinkResolver` and contain a `resolve_link(link)` method, as well as the `resolve_404(id)` method for broken links. For example, you can create `MyLinkResolver.rb`:

```ruby
class MyLinkResolver < Kentico::Kontent::Delivery::Resolvers::ContentLinkResolver
  def resolve_link(link)
    return "/coffees/#{link.url_slug}" if link.type.eql? 'coffee'
    return "/brewers/#{link.url_slug}" if link.type.eql? 'brewer'
  end

  def resolve_404(id)
    "/notfound?id=#{id}"
  end
end
```

Then create an object of this class when instantiating the DeliveryClient:

```ruby
delivery_client = Kentico::Kontent::Delivery::DeliveryClient.new project_id: '<your-project-id>',
                                                             content_link_url_resolver: MyLinkResolver.new
```

You can pass a `ContentLinkResolver` to the DeliveryQuery instead of the client if you only want to resolve links for that query, or they should be resolved differently:

```ruby
delivery_client = Kentico::Kontent::Delivery::DeliveryClient.new project_id: '<your-project-id>'
# Client doesn't use ContentLinkResolver, but query below will
delivery_client.items
               .with_link_resolver MyLinkResolver.new
```

The `ContentLink` object that is passed to your resolver contains the following attributes:

- **id**: the system.id of the linked content item
- **code_name**: the system.codename of the linked content item
- **type**: the content type of the linked content item
- **url_slug**: the URL slug of the linked content item, or nil if there is none

To resolve links in rich text elements, you must retrieve the text using `get_string`:

```ruby
item_resolver = Kentico::Kontent::Delivery::Resolvers::ContentLinkResolver.new(lambda do |link|
  return "/coffees/#{link.url_slug}" if link.type.eql? 'coffee'
  return "/brewers/#{link.url_slug}" if link.type.eql? 'brewer'
end)
delivery_client = Kentico::Kontent::Delivery::DeliveryClient.new project_id: '<your-project-id>',
                                                             content_link_url_resolver: item_resolver
delivery_client.item('coffee_processing_techniques').execute do |response|
  text = response.item.get_string 'body_copy'
end
```

## Resolving inline content

Existing content items can be inserted into a rich text element, or you can create new content items as components. You need to resolve these in your application just as with content links. You can register a resolver when you instantiate the client by passing it with the hash key `inline_content_item_resolver`:

```ruby
item_resolver = Kentico::Kontent::Delivery::Resolvers::InlineContentItemResolver.new(lambda do |item|
      return "<h1>#{item.elements.zip_code.value}</h1>" if item.system.type.eql? 'cafe'
      return "<div>$#{item.elements.price.value}</div>" if item.system.type.eql? 'brewer'
    end)
delivery_client = Kentico::Kontent::Delivery::DeliveryClient.new project_id: '<your-project-id>',
                                                             inline_content_item_resolver: item_resolver
```

The object passed to the resolving method is a complete ContentItem. Similar to content link resolvers, you can create your own class which extends `Kentico::Kontent::Delivery::Resolvers::InlineContentItemResolver` and implements the `resolve_item` method:

```ruby
class MyItemResolver < Kentico::Kontent::Delivery::Resolvers::InlineContentItemResolver
  def resolve_item(item)
    return "<h1>#{item.elements.zip_code.value}</h1>" if item.system.type.eql? 'cafe'
    return "<div>$#{item.elements.price.value}</div>" if item.system.type.eql? 'brewer'
  end
end
```

You can also set the inline content resolver per-query:

```ruby
delivery_client = Kentico::Kontent::Delivery::DeliveryClient.new project_id: '<your-project-id>'
# Client doesn't use InlineContentItemResolver, but query below will
delivery_client.items
               .with_inline_content_item_resolver MyItemResolver.new
```

## Image transformation

When you've obtained the URL for an asset, you can use our [Image Transformation API](https://developer.kenticocloud.com/v1/reference#image-transformation) to make on-the-fly modifications to the image. To do this, use the static `.transform` method of `Kentico::Kontent::Delivery::Builders::ImageTransformationBuilder`, then call the transformation methods. When you're done, call the `.url` method to get the new URL:

```ruby
url = response.item.get_assets('teaser_image').first.url
url = Kentico::Kontent::Delivery::Builders::ImageTransformationBuilder.transform(url)
                                                                  # methods...
                                                                  .url
```

The available methods are:

|Method|Possible values|REST example
|--|--|--|
|`.with_width`| positive integer, or float between 0 and 1| ?w=200
|`.with_height`| positive integer, or float between 0 and 1| ?h=200
|`.with_pixel_ratio`| float greater than 0 but less than 5| ?dpr=1.5
|`.with_fit_mode`| constants available at `Kentico::Kontent::Delivery::Builders::ImageTransformationBuilder` <ul><li>FITMODE_CROP</li><li>FITMODE_CLIP</li><li>FITMODE_SCALE</li></ul>| ?fit=crop
|`.with_rect`| 4 integer values representing pixels or floats representing percentages|rect=100,100,0.7,0.7
|`.with_focal_point`| 2 floats between 0 and 1 and one integer between 1 and 100| ?fp-x=0.2&fp-y=0.7&fp-z=5
|`.with_background_color`| string containing 3, 4, 6, or 8 characters | ?bg=7A0099EE
|`.with_output_format`| constants available at `Kentico::Kontent::Delivery::Builders::ImageTransformationBuilder` <ul><li>FORMAT_GIF</li><li>FORMAT_PNG</li><li>FORMAT_PNG8</li><li>FORMAT_JPG</li><li>FORMAT_PJPG</li><li>FORMAT_WEBP</li></ul> | ?fm=webp
|`.with_quality`| integer between 1 to 100 | ?quality=50
|`.with_lossless`| 'true', 'false', 0, or 1| ?lossless=1
|`.with_auto_format_selection`| 'true', 'false', 0, or 1 | ?auto=format

## Feedback & Contributing

Check out the [contributing](https://github.com/Kentico/kontent-delivery-sdk-ruby/blob/master/CONTRIBUTING.md) page to see the best places to file issues, start discussions, and begin contributing.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Delivery project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/Kentico/kontent-delivery-sdk-net/blob/master/CODE_OF_CONDUCT.md).

![Analytics](https://kentico-ga-beacon.azurewebsites.net/api/UA-69014260-4/Kentico/kontent-delivery-sdk-ruby?pixel)
