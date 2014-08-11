# Meteorlog

Meteorlog is a tool to manage CloudWatch Logs.

It defines the state of CloudWatch Logs using DSL, and updates CloudWatch Logs according to DSL.

[![Gem Version](https://badge.fury.io/rb/meteorlog.svg)](http://badge.fury.io/rb/meteorlog)

## Installation

Add this line to your application's Gemfile:

    gem 'meteorlog'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install meteorlog

## Usage

```sh
export AWS_ACCESS_KEY_ID='...'
export AWS_SECRET_ACCESS_KEY='...'
export AWS_REGION='us-east-1'
meteorlog -e -o Alarmfile  # export CloudWatch Alarm
vi Alarmfile
meteorlog -a --dry-run
meteorlog -a               # apply `Alarmfile` to CloudWatch
```

## Help

```
Usage: meteorlog [options]
    -p, --profile PROFILE_NAME
    -k, --access-key ACCESS_KEY
    -s, --secret-key SECRET_KEY
    -r, --region REGION
    -a, --apply
    -f, --file FILE
        --dry-run
    -e, --export
    -o, --output FILE
        --no-color
        --debug
```

## Logsfile example

```ruby
require 'other/logsfile'

log_group "/var/log/messages" do
  log_stream "my-stream"

  metric_filter "MyAppAccessCount" do
    metric :name=>"EventCount", :namespace=>"YourNamespace", :value=>"1"
  end

  metric_filter "MyAppAccessCount2" do
    filter_pattern '[...]'
    metric :name=>"EventCount2", :namespace=>"YourNamespace2", :value=>"2"
  end
end

log_group "/var/log/maillog" do
  log_stream "my-stream2"

  metric_filter "MyAppAccessCount" do
    metric :name=>"EventCount3", :namespace=>"YourNamespace", :value=>"1"
  end

  metric_filter "MyAppAccessCount2" do
    metric :name=>"EventCount4", :namespace=>"YourNamespace2", :value=>"2"
  end
end
```
