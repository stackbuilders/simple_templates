[![Build Status](https://travis-ci.org/stackbuilders/simple_templates.svg?branch=master)](https://travis-ci.org/stackbuilders/simple_templates)
[![No Maintenance Intended](http://unmaintained.tech/badge.svg)](http://unmaintained.tech/)

> **⚠️ Warning:** This library has been deprecated and is no longer maintained. It will not receive any further security patches, features, or bug fixes and is preserved here at GitHub for archival purposes. If you want to use it, we suggest forking the repository and auditing the codebase before use. For more information, contact us at info@stackbuilders.com.

# DEPRECATED - simple_templates

`simple_templates` is a minimalistic templates engine. This gem allows you to
work with several types of templates.

## Installation

Clone the project

```
git@github.com:stackbuilders/simple_templates.git
```

Install the dependencies

```
bundle install
```

Run the tests

```
rake test
```

## Quick Start

The basic use of the library can be seen like this:

You can send a `String` with the raw input that includes your placeholders and
a list of `String` containing the allowed placeholders, if it is `nil`, then all
the placeholders are allowed.

A example without errors, that allows us to call the method `render`

```ruby
  template = SimpleTemplates.parse("Hi <name>", %w[name])
  template.render({ name: "Bob" }) if template.errors.empty?
  => "Hi Bob"
  template.remaining_tokens
  => []
```

An example with errors. Since the allowed placeholder is not in the raw input.
So we get are going to get a list of errors when parsing

```ruby
  template = SimpleTemplates.parse("Hi <name>", %w[date])
  template.errors
  => [...] # unknown placeholder
```

### Serialization Support

You can serialize a template out of the box by calling the method `to_json`.

```ruby
  template = SimpleTemplates.parse("Hi <name>", %w[name])
  template.to_json
  # => "{\"ast\":[{\"contents\":\"Hi...
```

You can also deserialize a serialized template.

```ruby
  SimpleTemplates::Template.from_json(template.to_json)
  # => #<SimpleTemplates::Template:0x007fad96056ae0...
```

## Tasks

The default task executed by `rake` is only

```
rake test
```

Additionally you can generate the documentation by running

```
rake docs
```

## License

MIT. See [LICENSE](https://github.com/stackbuilders/simple_templates/blob/master/LICENSE)

---
<img src="https://cdn.stackbuilders.com/media/images/Sb-supports.original.png" alt="Stack Builders" width="50%"></img>  
[Check out our libraries](https://github.com/stackbuilders/) | [Join our team](https://www.stackbuilders.com/join-us/)
