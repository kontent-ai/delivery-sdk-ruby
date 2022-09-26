# Installation

Install [ruby](https://rubyinstaller.org/downloads/)
* use recommended version with devkit
* use preselected options when installing
* for [mingw](http://www.mingw.org/) selection just hit ENTER at the prompt `Which components shall be installed? If unsure press ENTER [1,2,3]`

Install bundler

`gem install bundler`

# Run tests
* `git clone https://github.com/kontent-ai/delivery-sdk-ruby.git`
* `cd delivery-sdk-ruby`
* Create a `.env` file with the environment variables below
  * You could generate [your own sample project](https://kontent.ai/learn/tutorials/manage-kontent-ai/projects/manage-projects/#a-create-a-sample-project)
  * Or, you can copy the keys from `.travis.yml`
```
PROJECT_ID=<PLACE PREVIEW API KEY>
PREVIEW_KEY=<PLACE PREVIEW API KEY>
SECURE_KEY=<PLACE SECURE API KEY>
```
* `bundle` (install all dependent packages)
* `bundle exec rake` - runs all Tests

If you want to run only one test, it is possible to use this command
* `rake spec SPEC=<PATH-TO-TEST> SPEC_OPTS="-e \"test identification (first it parameter)\""`
    * example `rake spec SPEC=spec/delivery_spec.rb SPEC_OPTS="-e \"handle empty value\""`

# Build your package
* `bundle` (install all dependent packages)
* `rake build`
  * creates file `delivery-sdk-ruby-<VERSION>.gem` file in the project's root folder