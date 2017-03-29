# simple_templates

[![Build Status](https://travis-ci.org/stackbuilders/simple_templates.svg?branch=master)](https://travis-ci.org/stackbuilders/simple_templates)


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
