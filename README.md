# Delivery

The Kentico Cloud Ruby SDK can be used in Ruby/Rails projects to retrieve content from Kentico Cloud. This is a community project and not an official Kentico SDK.

## Installation

You can build the Gem from source or point to this repository to use this Gem in your Ruby project. To use Bundler and download the source for this SDK without building it, add the following to your Gemfile:

```ruby
gem "delivery-sdk-ruby", :git => "git://github.com/Kentico/delivery-sdk-ruby.git"
```

Then run `bundle install`. To build the Gem yourself for local installation, clone this repository and run `rake build`. You can then install the Gem:

```ruby
gem install delivery-sdk-ruby-<version>.gem
```
Then, add the Gem to your Gemfile:

```ruby
gem "delivery-sdk-ruby"
```

## Usage

You will use`Delivery::DeliveryClient to obtain content from Kentico Cloud. First, create an instance of the client:

```ruby
client = Delivery::DeliveryClient.new 'your-project-id'
```

Use `.item` or `.items` to create a Delivery::DeliveryQuery, then call `.execute` to perform the request.

```ruby
client = Delivery::DeliveryClient.new('<your-project-id>')
client.items.execute do |response|
  response.items.each do |item|
    puts item.system.codename
  end
end
```

### Filtering

You can use [filtering](https://developer.kenticocloud.com/v1/reference#content-filtering "filtering") to retrieve particular items. The filtering methods are applied directly to a string and the available methods are:

- all
- any
- contains
- eq
- gt
- gt_or_eq
- in
- lt
- lt_or_eq
- range

For example:

```ruby
# Single filter
client.items('elements.price'.gt 20)

# Multiple filters
client.items [
  ('elements.price'.gt 20),
  ('system.type'.eq 'grinder')
]
```

## Parameters

The `.item` and `.items` methods return a `Delivery::DeliveryQuery` object which you can futher configure before executing. The methods you can call are:

- [order_by](https://developer.kenticocloud.com/v1/reference#content-ordering "order_by")
- [skip](https://developer.kenticocloud.com/v1/reference#listing-response-paging "skip")
- [limit](https://developer.kenticocloud.com/v1/reference#listing-response-paging "limit")
- [elements](https://developer.kenticocloud.com/v1/reference#projection "elements")
- [depth](https://developer.kenticocloud.com/v1/reference#linked-content "depth")

For example:

```ruby
client.items('system.type'.eq 'coffee')
  .depth(0)
  .limit(5)
  .elements(%W[price product_name])
  .execute do |response|
    # Do something
  end
```

## Responses

When you execute the DeliveryQuery, you will get a `DeliveryItemResponse` for single item queries, or a `DeliveryItemListingResponse` for multiple item queries. You can access the return ContentItem(s) at `.item` or `.items` respectively.

The `ContentItem` object gives you access to all system elements and content type elements at the `.system` and `.elements` properies. These are dynamic objects, so you can simply type the name of the element you need:

```ruby
response.item.elements.price.value
```

## Feedback & Contributing

Check out the [contributing](https://github.com/Kentico/delivery-sdk-ruby/blob/master/CONTRIBUTING.md) page to see the best places to file issues, start discussions, and begin contributing.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Delivery project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/Kentico/delivery-sdk-net/blob/master/CODE_OF_CONDUCT.md).

![Analytics](https://kentico-ga-beacon.azurewebsites.net/api/UA-69014260-4/Kentico/delivery-sdk-ruby?pixel)
