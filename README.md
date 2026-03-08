# Redmine Reaction Notifier

A Redmine plugin that sends email notifications to content authors when another user reacts to their post.

The reaction feature was introduced in Redmine 6.1 ([#42630](https://www.redmine.org/issues/42630)).

## Features

- Sends an email when someone reacts to content. Recipients are determined as follows:
  - **Issue**: the assigned user (`assigned_to`) if present; otherwise the issue author.
  - **Journal**: the user who created the journal entry.
  - **Message**, **News**, **WikiContent**: the content author.
- Skips notification when the reactor is the same person as the recipient (author or assignee).
- Skips notification when the recipient's account is inactive or has no email address.
- Respects the recipient's language setting for the notification email.
- **Users can enable/disable reaction notifications** in their account preferences (My account > Preferences).
  - By default, notifications are enabled.
  - No database table modifications required; uses Redmine's built-in `UserPreference` model.

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
