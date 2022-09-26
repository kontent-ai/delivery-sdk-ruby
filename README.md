![build](https://github.com/kontent-ai/delivery-sdk-ruby/actions/workflows/build.yml/badge.svg)
[![Join us on Discord](https://img.shields.io/discord/821885171984891914?label=Discord&logo=Discord&logoColor=white)](https://discord.gg/SKCxwPtevJ)
[![Stack Overflow](https://img.shields.io/badge/Stack%20Overflow-ASK%20NOW-FE7A16.svg?logo=stackoverflow&logoColor=white)](https://stackoverflow.com/tags/kontent-ai)
 [![Version](https://img.shields.io/gem/v/kontent-ai-delivery.svg?style=flat)](https://rubygems.org/gems/kontent-ai-delivery)

# Delivery Ruby SDK

![Banner](/banner.png)

The Delivery Ruby SDK can be used in Ruby/Rails projects to retrieve content from Kontent.ai. This is a community project and not an official Kontent.ai SDK. If you find a bug in the SDK or have a feature request, please submit a GitHub issue.

See [How to setup a development environment on Windows](https://github.com/kontent-ai/delivery-sdk-ruby/wiki/How-to-setup-development-environment-on-Windows) for local development, and check out the [Kontent.ai Blog](https://kontent.ai/blog/creating-a-kentico-cloud-ruby-on-rails-application) for a tutorial on creating a Rails application.

## Table of contents

- [Installation](#installation)
- [Creating a client](#creating-a-client)
  - [Previewing unpublished content](#previewing-unpublished-content)
  - [Making secure requests](#making-secure-requests)
  - [Retry policy](#retry-policy)
  - [Custom URLs](#custom-urls)
- [Listing items](#listing-items)
  - [Filtering](#filtering)
  - [Parameters](#parameters)
  - [Responses](#responses)
  - [Requesting the latest content](#requesting-the-latest-content)
  - [Providing custom headers](#providing-custom-headers)
  - [Pagination](#pagination)
- [Working with content items](#working-with-content-items)
  - [Assets](#assets)
  - [Linked items](#linked-items)
  - [Resolving links](#resolving-links)
  - [Resolving inline content](#resolving-inline-content)
- [Items feed](#items-feed)
- [Retrieving content types](#retrieving-content-types)
- [Retrieving taxonomy](#retrieving-taxonomy)
- [Retrieving content type elements](#retrieving-content-type-elements)
- [Retrieving languages](#retrieving-languages)
- [Image transformation](#image-transformation)

## Installation

To use the SDK in your own project, add the gem to your Gemfile:

```ruby
gem 'delivery-sdk-ruby'
```

Then run `bundle install`. You can also download the gem from [RubyGems.org](https://rubygems.org/gems/delivery-sdk-ruby). To use the SDK in an `.rb` file, you need to require it:

```ruby
require 'delivery-sdk-ruby'
```

## Creating a client

You will use `Kontent::Ai::Delivery::DeliveryClient` to obtain content from Kontent.ai. Create an instance of the client and pass your project ID:

```ruby
delivery_client = Kontent::Ai::Delivery::DeliveryClient.new project_id: '<your-project-id>'
```

:gem: **Pro tip:** You can alias namespaces to make them shorter, e.g.

```ruby
KA = Kontent::Ai::Delivery
delivery_client = KA::DeliveryClient.new project_id: '<your-project-id>'
```

### Previewing unpublished content

To [enable preview](https://kontent.ai/learn/tutorials/develop-apps/build-strong-foundation/set-up-preview "See how to configure your app and Kontent.ai project to enable content preview"), pass the Preview API Key to the constructor:

```ruby
delivery_client = Kontent::Ai::Delivery::DeliveryClient.new project_id: '<your-project-id>',
                                                                 preview_key: '<your-preview-key>'
```

This enables preview, but you can toggle preview at any time by setting the `use_preview` attribute of `DeliveryClient` which is propagated to all queries created by the client, _or_ per-query by setting its `use_preview` attribute:

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

If you've [secured access](https://kontent.ai/learn/tutorials/develop-apps/build-strong-foundation/restrict-public-access "See how to enable secured access for your Kontent.ai project") to your project, you need to provide the `DeliveryClient` with either the primary or secondary key:

```ruby
Kontent::Ai::Delivery::DeliveryClient.new project_id: '<your-project-id>',
                                               secure_key: '<your-secure-key>'
```

You can then securely request published content in your project. Be sure to not expose the key if the file(s) it appears in are publicly available.

### Retry policy

By default, the SDK uses a retry policy, asking for requested content again in case of an error. The default policy retries the HTTP request if the following status codes are returned:

* 408 - `RequestTimeout`
* 429 - `TooManyRequests`
* 500 - `InternalServerError`
* 502 - `BadGateway`
* 503 - `ServiceUnavailable`
* 504 - `GatewayTimeout`

The SDK will perform a total of 6 attempts at a maximum of 30 seconds to retrieve content before returning a `ResponseBase` object containing the error. The consecutive attempts are delayed with [exponential backoff and jitter](https://aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter/).

To disable the retry policy, you can use the `with_retry_policy` argument:

```ruby
Kontent::Ai::Delivery::DeliveryClient.new project_id: '<your-project-id>',
                                               secure_key: '<your-secure-key>',
                                               with_retry_policy: false
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

## Listing items


Use `.item` or `.items` to create a `Kontent::Ai::Delivery::DeliveryQuery`, then call `.execute` to perform the request.

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

You can use [filtering](https://kontent.ai/learn/reference/delivery-api#tag/Filtering-content "See content filtering options in Delivery API") to retrieve particular items. The filtering methods are applied directly to a string and the available methods are:

|Method|Example|REST equivalent|
|--|--|--|
|all|`'elements.product_status'.all %w[bestseller on_sale]`|?elements.product_status[all]=bestseller,on_sale|
|any|`'elements.processing'.any %w[dry__natural_ semi_dry]`|?elements.processing[any]=dry__natural_,semi_dry|
|contains|`'elements.related_articles'.contains 'on_roasts'`|?elements.related_articles[contains]=on_roasts|
|eq|`'system.type'.eq 'grinder'`|?system.type=grinder|
|not_eq|`'elements.region'.not_eq  'USA'`|?elements.region[neq]=USA|
|gt|`'elements.price'.gt 20`|?elements.price[gt]=20|
|gt_or_eq|`'elements.price'.gt_or_eq 20`|?elements.price[gte]=20|
|in|`'system.type'.in %w[coffee brewer]`|?system.type[in]=coffee,brewer|
|not_in|`'elements.author'.not_in %w[mberry ericd anthonym]`|?elements.author[nin]=mberry,ericd,anthonym|
|lt|`'elements.price'.lt 20`|?elements.price[lt]=20|
|lt_or_eq|`'elements.price'.lt_or_eq 20`|?elements.price[lte]=20|
|range|`'system.last_modified'.range %w[2018-02-01 2018-03-31]`|?system.last_modified[range]=2018-02-01,2018-03-31|
|empty|`'elements.banned_reason'.empty`|?elements.banned_reason[empty]|
|not_empty|`'elements.status'.not_empty`|?elements.status[nempty]|

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

The `.item` and `.items` methods return a `Kontent::Ai::Delivery::DeliveryQuery` object which you can further configure before executing. The methods you can call are:

|Method|Example|REST equivalent
|--|--|--|
|[order_by](https://kontent.ai/learn/reference/delivery-api#operation/list-content-items "order_by")|`order_by 'system.last_modified' '[desc]'`|?order=system.last_modified[desc]
|[skip](https://kontent.ai/learn/reference/delivery-api#operation/list-content-items "skip")|`skip 5`|?skip=5
|[limit](https://kontent.ai/learn/reference/delivery-api#operation/list-content-items "limit")|`limit 5`|?limit=5
|[elements](https://kontent.ai/learn/reference/delivery-api#tag/Projection "elements")|`elements %w[price product_name image]`|?elements=price,product_name,image
|[depth](https://kontent.ai/learn/reference/delivery-api#tag/Linked-content-and-components/linked-content-depth "depth")|`depth 0`|?depth=0
|[language](https://kontent.ai/learn/tutorials/manage-kontent/projects/set-up-languages#a-language-fallbacks "language")|`language 'en'`|?language=en

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

### Responses

All responses from the `.execute` method will be/extend the `Kontent::Ai::Delivery::Responses::ResponseBase` class which contains the following attributes:

- **http_code**: The HTTP status code of the response
- **headers**: The headers of the response
- **json**: The full JSON body of the response

You can check the response code to determine if the request was successful:

```ruby
delivery_client.items.execute do |response|
  case response.http_code
  when 200
    # Success!
  when 401
    # Did you forget the secure key?
  else
    # to_s displays a friendly message with details of the response
    puts response.to_s
  end
end
```

For successful content item queries, you will get either `DeliveryItemResponse` for single item queries, or `DeliveryItemListingResponse` for multiple item queries. You can access the returned content item(s) at `.item` or `.items` respectively.

The `ContentItem` object gives you access to all system elements and content type elements at the `.system` and `.elements` properies. These are dynamic objects, so you can simply type the name of the element you need:

```ruby
price = response.item.elements.price.value
```

### Requesting the latest content

Kontent.ai caches content using Fastly, so requests made to Kontent.ai may not be up-to-date. In some cases, such as when reacting to [webhook](https://kontent.ai/learn/tutorials/develop-apps/integrate/webhooks) notifications, you might want to request the latest content from your Kontent.ai project.

You can check the headers of the response for the **X-Stale-Content** header to check if the response was served from cache:

```ruby
delivery_client.item('about_us').execute do |response|
  if response.headers[:x_stale_content].eq 1
    ## Content is stale
  end
end
```

You can bypass the cache and get the latest content using `request_latest_content`

```ruby
delivery_client.item('about_us')
  .request_latest_content
  .execute
```

### Providing custom headers

If you want to pass custom headers in the request, you can use `custom_headers`. This could be useful when you are developing your package on top of the SDK.

Note that you can not override internal headers such as `Authorization`. If headers with an existing key are passed into the method, they will be ignored.

```ruby
delivery_client.items
  .custom_headers({ 'MY-HEADER' => 'HEADER VALUE' })
  .execute
```

### Pagination

Most responses also contain a `pagination` attribute to access the [paging](https://kontent.ai/learn/reference/delivery-api#operation/list-content-items "paging") data for the Delivery query. This object contains the following attributes:

- **skip**
- **limit**
- **count**
- **next_page**
- **total_count** (only if `include_total_count` is called)

For example, to access the next page URL you can use:

```ruby
delivery_client.items
    .skip(0)
    .limit(5)
    .include_total_count
    .execute do |response|
      next_page_url = response.pagination.next_page
    end
```

:warning: Note that using the `include_total_count` method may increase the response time and should only be used if necessary.

## Working with content items

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

### Resolving links

If a rich text element contains links to other content items, you will need to generate the URLs to those items. You can do this by registering a `Kontent::Ai::Delivery::Resolvers::ContentLinkResolver` when you instantiate the DeliveryClient. When you create a ContentLinkResolver, you must pass a method that will return the URL, and you may pass another method that will be called if the content contains a link, but the content item is not present in the response:

```ruby
link_resolver = Kontent::Ai::Delivery::Resolvers::ContentLinkResolver.new(lambda do |link|
        # Link valid
        return "/coffees/#{link.url_slug}" if link.type.eql? 'coffee'
        return "/brewers/#{link.url_slug}" if link.type.eql? 'brewer'
      end, lambda do |id|
        # Link broken
        return "/notfound?id=#{id}"
      end)
delivery_client = Kontent::Ai::Delivery::DeliveryClient.new project_id: '<your-project-id>',
                                                             content_link_url_resolver: link_resolver
```

You can also build the logic for your resolver in a separate class and register an instance of that class in the DeliveryClient. The class must extend `Kontent::Ai::Delivery::Resolvers::ContentLinkResolver` and contain a `resolve_link(link)` method, as well as the `resolve_404(id)` method for broken links. For example, you can create `MyLinkResolver.rb`:

```ruby
class MyLinkResolver < Kontent::Ai::Delivery::Resolvers::ContentLinkResolver
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
delivery_client = Kontent::Ai::Delivery::DeliveryClient.new project_id: '<your-project-id>',
                                                             content_link_url_resolver: MyLinkResolver.new
```

You can pass a `ContentLinkResolver` to the DeliveryQuery instead of the client if you only want to resolve links for that query, or they should be resolved differently:

```ruby
delivery_client = Kontent::Ai::Delivery::DeliveryClient.new project_id: '<your-project-id>'
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
item_resolver = Kontent::Ai::Delivery::Resolvers::ContentLinkResolver.new(lambda do |link|
  return "/coffees/#{link.url_slug}" if link.type.eql? 'coffee'
  return "/brewers/#{link.url_slug}" if link.type.eql? 'brewer'
end)
delivery_client = Kontent::Ai::Delivery::DeliveryClient.new project_id: '<your-project-id>',
                                                             content_link_url_resolver: item_resolver
delivery_client.item('coffee_processing_techniques').execute do |response|
  text = response.item.get_string 'body_copy'
end
```

### Resolving inline content

Existing content items can be inserted into a rich text element, or you can create new content items as components. You need to resolve these in your application just as with content links. You can register a resolver when you instantiate the client by passing it with the hash key `inline_content_item_resolver`:

```ruby
item_resolver = Kontent::Ai::Delivery::Resolvers::InlineContentItemResolver.new(lambda do |item|
      return "<h1>#{item.elements.zip_code.value}</h1>" if item.system.type.eql? 'cafe'
      return "<div>$#{item.elements.price.value}</div>" if item.system.type.eql? 'brewer'
    end)
delivery_client = Kontent::Ai::Delivery::DeliveryClient.new project_id: '<your-project-id>',
                                                             inline_content_item_resolver: item_resolver
```

The object passed to the resolving method is a complete ContentItem. Similar to content link resolvers, you can create your own class which extends `Kontent::Ai::Delivery::Resolvers::InlineContentItemResolver` and implements the `resolve_item` method:

```ruby
class MyItemResolver < Kontent::Ai::Delivery::Resolvers::InlineContentItemResolver
  def resolve_item(item)
    return "<h1>#{item.elements.zip_code.value}</h1>" if item.system.type.eql? 'cafe'
    return "<div>$#{item.elements.price.value}</div>" if item.system.type.eql? 'brewer'
  end
end
```

You can also set the inline content resolver per-query:

```ruby
delivery_client = Kontent::Ai::Delivery::DeliveryClient.new project_id: '<your-project-id>'
# Client doesn't use InlineContentItemResolver, but query below will
delivery_client.items
               .with_inline_content_item_resolver MyItemResolver.new
```

To resolve inline content in elements, you must call `get_string` similar to content item links:

```ruby
item_resolver = Kontent::Ai::Delivery::Resolvers::InlineContentItemResolver.new(lambda do |item|
  return "<div>$#{item.elements.price.value}</div>" if item.system.type.eql? 'brewer'
end)
delivery_client = Kontent::Ai::Delivery::DeliveryClient.new project_id: PROJECT_ID,
                                                            inline_content_item_resolver: item_resolver
delivery_client.item('our_brewers').execute do |response|
  text = response.item.get_string 'body_copy'
end
```

## Items feed

Use the `items_feed` method to retrieve a dynamically paginated list of content items in your project. The result will have a `more_results?` method which indicates that more items can be retrieved from the feed, using the `next_result` method.

This method accepts all [filtering](#filtering) and [parameters](https://github.com/kontent-ai/delivery-sdk-ruby#parameters) except _depth_, _skip_, and _limit_. You can read more about the /items-feed endpoint in the [Delivery API reference](https://kontent.ai/learn/reference/delivery-api#operation/enumerate-content-items)

Below is an example that will load all content items of a project into a single array:

```ruby
result = delivery_client.items_feed.execute
items = result.items
if result.more_results?
  loop do
    result = result.next_result
    items.push *result.items
    break unless result.more_results?
  end
end
```

## Retrieving content types

You can use the `.type` and `.types` methods to request your content types from Kontent.ai:

```ruby
delivery_client.types.execute do |response|
  # Do something
end
delivery_client.type('coffee').execute do |response|
  # Do something
end
```

As with content item queries, all content type queries will return a `Kontent::Ai::Delivery::Responses::ResponseBase` of the class `DeliveryTypeResponse` or `DeliveryTypeListingResponse` for single and multiple type queries, respectively.

For multiple type queries, you can access the array of `ContentType` objects at `.types`, and at `.type` for singe type queries. You can access information about the type(s) dynamically:

```ruby
delivery_client.type('coffee').execute do |response|
  field_type = response.type.elements.product_status.type # taxonomy
end
```
The DeliveryTypeListingResponse also contains pagination data, similar to DeliveryItemListingResponse.

## Retrieving taxonomy

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

Each response will return either a single `Kontent::Ai::Delivery::TaxonomyGroup` or an array of groups. The taxonomy group(s) are accessible at `.taxonomy` and `.taxonomies` for single and multiple queries, respectively.

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

Kontent.ai provides an [endpoint](https://kontent.ai/learn/reference/delivery-api#operation/retrieve-a-content-element) for obtaining details about a specific element of a content type. In the Ruby SDK, you can use the `.element` method:

```ruby
delivery_client.element('brewer', 'product_status').execute do |response|
  puts response.element.type # taxonomy
end
```

This returns a `Kontent::Ai::Delivery::Responses::DeliveryElementResponse` where the `element` attribute is a dynamic OStruct representation of the JSON response. This means that you can access any property of the element by simply typing the name as in the above example.

The element will always contain __codename__, __type__, and __name__, but multiple choice elements will also contain __options__ and taxonomy elements will contain __taxonomy_group__. The Ruby SDK fully supports obtaining [custom elements](https://kontent.ai/learn/reference/custom-elements-js-api) using this approach and any other methods.

## Retrieving languages

Use the `.languages` method to list all of the languages in the project:

```ruby
delivery_client.languages.execute do |response|
  puts response.languages.length # number of languages
end
```

The response is a `Kontent::Ai::Delivery::Responses::DeliveryLanguageListingResponse` where `languages` is an array of all langauges. You can access the system properties of each language as they are returned by Kontent:

```ruby
delivery_client.languages.execute do |response|
  puts response.languages[0].system.codename # en-us
end
```

## Image transformation

When you've obtained the URL for an asset, you can use our [Image Transformation API](https://kontent.ai/learn/reference/image-transformation) to make on-the-fly modifications to the image. To do this, use the static `.transform` method of `Kontent::Ai::Delivery::Builders::ImageTransformationBuilder`, then call the transformation methods. When you're done, call the `.url` method to get the new URL:

```ruby
url = response.item.get_assets('teaser_image').first.url
url = Kontent::Ai::Delivery::Builders::ImageTransformationBuilder.transform(url)
                                                                      # methods...
                                                                      .url
```

The available methods are:

|Method|Possible values|REST example
|--|--|--|
|`.with_width`| positive integer, or float between 0 and 1| ?w=200
|`.with_height`| positive integer, or float between 0 and 1| ?h=200
|`.with_pixel_ratio`| float greater than 0 but less than 5| ?dpr=1.5
|`.with_fit_mode`| constants available at `Kontent::Ai::Delivery::Builders::ImageTransformationBuilder` <ul><li>FITMODE_CROP</li><li>FITMODE_CLIP</li><li>FITMODE_SCALE</li></ul>| ?fit=crop
|`.with_rect`| 4 integer values representing pixels or floats representing percentages|rect=100,100,0.7,0.7
|`.with_focal_point`| 2 floats between 0 and 1 and one integer between 1 and 100| ?fp-x=0.2&fp-y=0.7&fp-z=5
|`.with_background_color`| string containing 3, 4, 6, or 8 characters | ?bg=7A0099EE
|`.with_output_format`| constants available at `Kontent::Ai::Delivery::Builders::ImageTransformationBuilder` <ul><li>FORMAT_GIF</li><li>FORMAT_PNG</li><li>FORMAT_PNG8</li><li>FORMAT_JPG</li><li>FORMAT_PJPG</li><li>FORMAT_WEBP</li></ul> | ?fm=webp
|`.with_quality`| integer between 1 to 100 | ?quality=50
|`.with_lossless`| 'true', 'false', 0, or 1| ?lossless=1
|`.with_auto_format_selection`| 'true', 'false', 0, or 1 | ?auto=format

## Feedback & Contributing

Check out the [contributing](CONTRIBUTING.md) page to see the best places to file issues, start discussions, and begin contributing.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Delivery project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](CODE_OF_CONDUCT.md).

## Wall of Fame

We would like to express our thanks to the following people who contributed and made the project possible:

* [Eric Dugre](https://github.com/kentico-ericd) - the original author of the SDK

Would you like to become a hero too? Pick an [issue](https://github.com/kontent-ai/delivery-sdk-ruby/issues) and send us a pull request!

