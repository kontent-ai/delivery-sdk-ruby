
[![Forums](https://img.shields.io/badge/chat-on%20forums-orange.svg)](https://forums.kenticocloud.com) [![Join the chat at https://kentico-community.slack.com](https://img.shields.io/badge/join-slack-E6186D.svg)](https://kentico-community.slack.com) [![Version](https://img.shields.io/badge/version-0.6.0-green.svg)](https://github.com/Kentico/delivery-sdk-ruby/blob/master/lib/delivery/version.rb)

# Delivery Ruby SDK

The Delivery Ruby SDK can be used in Ruby/Rails projects to retrieve content from Kentico Cloud. This is a community project and not an official Kentico SDK. If you find a bug in the SDK or have a feature request, please submit a GitHub issue.

## Installation

You can connect your Ruby/Rails application directly to this repo. Add the following to your Gemfile:

```ruby
gem 'delivery-sdk-ruby', :git => 'https://github.com/Kentico/delivery-sdk-ruby.git'
gem 'rest-client'
```

Then run `bundle install`. To use the SDK within a `.rb` file, you need to `require` it:

```ruby
require 'delivery-sdk-ruby'
```

You can also build the Gem locally by cloning this repo and running `rake build`.

## Creating a client

You will use `Delivery::DeliveryClient` to obtain content from Kentico Cloud. Create an instance of the client and pass your project ID:

```ruby
require 'delivery/client/delivery_client'

delivery_client = Delivery::DeliveryClient.new project_id: '<your-project-id>'
```

### Previewing unpublished content

To enable [preview](https://developer.kenticocloud.com/docs/previewing-content-in-a-separate-environment "preview"), pass the Preview API Key to the constructor:

```ruby
delivery_client = Delivery::DeliveryClient.new project_id: '<your-project-id>',
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
Delivery::DeliveryClient.new project_id: '<your-project-id>',
                             secure_key: '<your-secure-key>'
```

## Listing items


Use `.item` or `.items` to create a `Delivery::DeliveryQuery`, then call `.execute` to perform the request.

```ruby
delivery_client.items.execute do |response|
  response.items.each do |item|
    # Do something
  end
end
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

The `.item` and `.items` methods return a `Delivery::DeliveryQuery` object which you can further configure before executing. The methods you can call are:

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

### Custom URLs

When you have a URL (i.e. `next_page` for paging, for testing purposes, or if you prefer to build it on your own) and still want to leverage SDK functionality such as rich text resolving, use the .url method:

```ruby
delivery_client.items
  .url('https://deliver.kenticocloud.com/<your-project-id>/items?system.type=grinder')
  .execute do |response|
    # Do something
  end
```

## Responses

All responses from the `.execute` method will be/extend the `Delivery::Responses::ResponseBase` class which contains an `http_code` attribute and a friendly message that can be displayed by calling `.to_s`. You can check the code to determine if the request was successful:

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

For successful queries, you will get either `DeliveryItemResponse` for single item queries, or `DeliveryItemListingResponse` for multiple item queries. You can access the returned content item(s) at `.item` or `.items` respectively.

The `ContentItem` object gives you access to all system elements and content type elements at the `.system` and `.elements` properies. These are dynamic objects, so you can simply type the name of the element you need:

```ruby
response.item.elements.price.value
```

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

## Resolving links

If a rich text element contains links to other content items, you will need to generate the URLs to those items. You can do this by registering a `Delivery::Resolvers::ContentLinkResolver` when you instantiate the DeliveryClient. When you create a ContentLinkResolver, you must pass a method that will return the URL:

```ruby
require 'delivery/resolvers/content_link_resolver'

link_resolver = Delivery::Resolvers::ContentLinkResolver.new(lambda do |link|
  return "/coffees/#{link.url_slug}" if link.type == 'coffee'
  return "/brewers/#{link.url_slug}" if link.type == 'brewer'
end)
delivery_client = Delivery::DeliveryClient.new project_id: '<your-project-id>',
                                content_link_url_resolver: link_resolver
```

You can also build the logic for your resolver in a separate class and register an instance of that class in the DeliveryClient. The class must extend `Delivery::Resolvers::ContentLinkResolver` and contain a `resolve_link(link)` method. For example, you can create `MyLinkResolver.rb`:

```ruby
require 'delivery/resolvers/content_link_resolver'

class MyLinkResolver < Delivery::Resolvers::ContentLinkResolver
  def resolve_link(link)
    return "/coffees/#{link.url_slug}" if link.type == 'coffee'
    return "/brewers/#{link.url_slug}" if link.type == 'brewer'
  end
end
```

Then create an object of this class when instantiating the DeliveryClient:

```ruby
delivery_client = Delivery::DeliveryClient.new project_id: '<your-project-id>',
                                content_link_url_resolver: MyLinkResolver.new
```

The `ContentLink` object that is passed to your resolver contains the following attributes:

- **id**: the system.id of the linked content item
- **code_name**: the system.codename of the linked content item
- **type**: the content type of the linked content item
- **url_slug**: the URL slug of the linked content item, or nil if there is none

To resolve links in rich text elements, you must retrieve the text using `get_string`:

```ruby
require 'delivery/resolvers/content_link_resolver'

lambda_resolver = Delivery::Resolvers::ContentLinkResolver.new(lambda do |link|
  return "/coffees/#{link.url_slug}" if link.type == 'coffee'
  return "/brewers/#{link.url_slug}" if link.type == 'brewer'
end)
delivery_client = Delivery::DeliveryClient.new project_id: '<your-project-id>',
                                content_link_url_resolver: lambda_resolver
delivery_client.item('coffee_processing_techniques').execute do |response|
  text = response.item.get_string 'body_copy'
end
```

## Feedback & Contributing

Check out the [contributing](https://github.com/Kentico/delivery-sdk-ruby/blob/master/CONTRIBUTING.md) page to see the best places to file issues, start discussions, and begin contributing.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Delivery project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/Kentico/delivery-sdk-net/blob/master/CODE_OF_CONDUCT.md).

![Analytics](https://kentico-ga-beacon.azurewebsites.net/api/UA-69014260-4/Kentico/delivery-sdk-ruby?pixel)
