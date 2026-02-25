# Redmine Reaction Notifier

A Redmine plugin that sends email notifications to content authors when another user reacts to their post.

The reaction feature was introduced in Redmine 6.1 ([#42630](https://www.redmine.org/issues/42630)).

## Features

- Sends an email to the author of an issue, journal note, forum message, news item, or wiki page when someone reacts to it.
- Skips notification when the reactor is the same person as the author.
- Skips notification when the author's account is inactive or has no email address.
- Respects the author's language setting for the notification email.

## Requirements

- Redmine 6.1 or higher

## Installation

1. Copy (or clone) this plugin into `plugins/redmine_reaction_notifier` inside your Redmine installation.
2. Restart Redmine.

## Running Tests

```bash
cd /path/to/redmine
bundle exec ruby -Iplugins/redmine_reaction_notifier/test \
  plugins/redmine_reaction_notifier/test/mailers/reaction_notifier_mailer_test.rb
```

## License

- GPLv2
