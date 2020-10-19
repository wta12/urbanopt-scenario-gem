# URBANopt Scenario Gem

### [back to main docs](../)

The URBANopt&trade; Scenario Gem includes functionality for defining scenarios, running simulations, and post-processing results. User defined SimulationMapper classes translate each Feature to a SimulationDir which is a directory containing simulation input files. A ScenarioRunner is used to perform simulations for each SimulationDir. Finally, a ScenarioPostProcessor can run on a Scenario to generate scenario level results.

[RDoc Documentation](https://urbanopt.github.io/urbanopt-scenario-gem/rdoc)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'urbanopt-scenario'
```

And then execute:

    $ bundle install
    $ bundle update

Or install it yourself as:

    $ gem install 'urbanopt-scenario'

## Testing

Check out the repository and then execute:

    $ bundle install
    $ bundle update    
    $ bundle exec rake
    
## Releasing

* Update change log
* Update version in `/lib/urbanopt/scenario/version.rb`
* Merge down to master
* run `rake release` from master
