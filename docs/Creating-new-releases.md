# Create new releases

_This page is primarily for the maintainers of this repository._

To publish the new version of the delivery-sdk-ruby gem, follow these steps:

1. Increase version in `/lib/delivery/version.rb`
   - Follow the [Semantic versioning system](https://semver.org)
2. Create a pull request with the change
3. After the pull request is merged to the `master` branch, [Create a new release](https://github.com/kontent-ai/delivery-sdk-ruby/releases/new)
   - **Use tag syntax as is recommended**
   - **Use the same version as it is in `version.rb` file**
4. _After the successful release a new GitHub action `publish-gem` is run and the new version is published automatically to [rubygems](https://rubygems.org/gems/kontent-ai-delivery)_

> If you have any problem, please contact the [code owners of this repository](https://github.com/kontent-ai/delivery-sdk-ruby/blob/master/.github/CODEOWNERS).
