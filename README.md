[![Forums](https://img.shields.io/badge/chat-on%20forums-orange.svg)](https://forums.kenticocloud.com) [![Join the chat at https://kentico-community.slack.com](https://img.shields.io/badge/join-slack-E6186D.svg)](https://kentico-community.slack.com) [![Version](https://img.shields.io/badge/version-0.4.0-green.svg)](https://github.com/Kentico/delivery-sdk-ruby/blob/master/lib/delivery/version.rb)

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

## Listing items

You will use `Delivery::DeliveryClient` to obtain content from Kentico Cloud. First, create an instance of the client:

```ruby
delivery_client = Delivery::DeliveryClient.new project_id: '<your-project-id>'
```

To enable [preview](https://developer.kenticocloud.com/docs/previewing-content-in-a-separate-environment "preview"), pass the Preview API Key to the constructor:

```ruby
delivery_client = Delivery::DeliveryClient.new project_id: '<your-project-id>',
  preview_key: '<your-preview-key>'
```

This enables preview, but you can toggle preview at any time by setting the `use_preview` attribute of DeliveryClient:

```ruby
delivery_client.use_preview = false
```

Use `.item` or `.items` to create a `Delivery::DeliveryQuery`, then call `.execute` to perform the request.

```ruby
delivery_client = Delivery::DeliveryClient.new project_id: '<your-project-id>'
delivery_client.items.execute do |response|
  response.items.each do |item|
    # Do something
  end
end
```

### Filtering

You can use [filtering](https://developer.kenticocloud.com/v1/reference#content-filtering "filtering") to retrieve particular items. The filtering methods are applied directly to a string and the available methods are:

- **all**
- **any**
- **contains**
- **eq**
- **gt**
- **gt_or_eq**
- **in**
- **lt**
- **lt_or_eq**
- **range**

For example:

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

The `.item` and `.items` methods return a `Delivery::DeliveryQuery` object which you can futher configure before executing. The methods you can call are:

- [order_by](https://developer.kenticocloud.com/v1/reference#content-ordering "order_by")
- [skip](https://developer.kenticocloud.com/v1/reference#listing-response-paging "skip")
- [limit](https://developer.kenticocloud.com/v1/reference#listing-response-paging "limit")
- [elements](https://developer.kenticocloud.com/v1/reference#projection "elements")
- [depth](https://developer.kenticocloud.com/v1/reference#linked-content "depth")
- [language](https://developer.kenticocloud.com/docs/understanding-language-fallbacks "language")

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

When you execute the query, you will get a `DeliveryItemResponse` for single item queries, or a `DeliveryItemListingResponse` for multiple item queries. You can access the returned content item(s) at `.item` or `.items` respectively.

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

## Resolving links

If a rich text element contains links to other content items, you will need to generate the URLs to those items. You can do this by registering a `Delivery::Resolvers::ContentLinkResolver` when you instantiate the DeliveryClient. When you create a ContentLinkResolver, you must pass a method that will return the URL:

```ruby
link_resolver = Delivery::Resolvers::ContentLinkResolver.new(lambda do |link|
  return "/coffees/#{link.url_slug}" if link.type == 'coffee'
  return "/brewers/#{link.url_slug}" if link.type == 'brewer'
end)
delivery_client = Delivery::DeliveryClient.new project_id: '<your-project-id>',
                                content_link_url_resolver: link_resolver
```

You can also build the logic for your resolver in a separate class and register an instance of that class in the DeliveryClient. The class must extend `Delivery::Resolvers::ContentLinkResolver` and contain a `resolve_link(link)` method. For example, you can create `MyLinkResolver.rb`:

```ruby
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
