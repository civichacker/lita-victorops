# VictorOps Handler for Lita

## Description
This Lita handler allows your bot to join your VictorOps timeline.  You can then address Hubot with timeline chat messages in the usual way:

```
@bo karma worst
```

## Installation

Add lita-victorops to your Lita instance's Gemfile:

``` ruby
gem "lita-victorops"
```

## Configuration


### Required

* `token` (String) – Your Lita instance will need a login key to connect to VictorOps.  Your Lita key is available at the "Lita" link of your VictorOps Integrations page.

### Example

``` ruby
Lita.configure do |config|
    config.robot.adapter = "victorops"
    config.adapters.victorops.token = ENV['VICTOROPS_TOKEN']
end
```


## Usage

TODO: Describe the plugin's features and how to use them.

## Copyright

Copyright &copy; 2020 Civic Hacker, LLC.
