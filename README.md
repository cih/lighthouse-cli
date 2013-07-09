# Lighthouse CLI

A lightweight and simple CLI for interacting with Lighthouse.

This is wrapper around the [lighthouse-api](https://github.com/entp/lighthouse-apiouse-api) gem. Show, list and update tickets without leaving the command line.

## Usage

Install the gem, add your api key and set the current project.

```
  gem install lighthouse-cli
  lighthouse -a your_key_here -c project_name_here
```

Here are some commands to give you an idea of what it can do.

```
  lighthouse -t 123 # Show ticket
  lighthouse -t 123 -s resolved # Update ticket state
  lighthouse -ot 123 -s resolved # Update ticket state, then open in browser
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


