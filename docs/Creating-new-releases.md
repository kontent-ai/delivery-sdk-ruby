# Create new releases

_This page is primarily for the maintainers of this repository._

To publish the new version of the kontent-ai-delivery gem, follow these steps:

1. Increase version in both `kontent-ai-delivery.gemspec` and `/lib/delivery/client/delivery_query.rb` (HEADER_SDK_VALUE)
   - Follow the [Semantic versioning system](https://semver.org)
2. Make sure tests are passing, add new tests if needed
3. Create a pull request with the change
4. After the pull request is merged to the `master` branch, [Create a new release](https://github.com/kontent-ai/delivery-sdk-ruby/releases/new)
   - **Use tag syntax as is recommended**
   - **Use the same version as it is in `kontent-ai-delivery.gemspec` file**
5. _After the successful release a new GitHub action `publish-gem` is run and the new version is published automatically to [rubygems](https://rubygems.org/gems/kontent-ai-delivery)_

> If you have any problem, please contact the [code owners of this repository](https://github.com/kontent-ai/delivery-sdk-ruby/blob/master/.github/CODEOWNERS).
