# URBANopt Scenario Gem 

The URBANopt&trade; Scenario Gem includes functionality for defining scenarios, running simulations, and post-processing results. User defined SimulationMapper classes translate each Feature to a SimulationDir which is a directory containing simulation input files. The ScenarioRunner is used to perform simulations for each SimulationDir. Finally, a ScenarioPostProcessor can run on a Scenario to generate scenario level results.

[RDoc Documentation](https://urbanopt.github.io/urbanopt-scenario-gem/)

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

* Update CHANGELOG.md
* Run `rake rubocop:auto_correct`
* Update version in `/lib/urbanopt/scenario/version.rb`
* Create PR to master, after tests and reviews complete, then merge
* Locally - from the master branch, run `rake release`
* On GitHub, go to the releases page and update the latest release tag. Name it “Version x.y.z” and copy the CHANGELOG entry into the description box.
