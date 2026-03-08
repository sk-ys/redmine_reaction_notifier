require_relative 'lib/redmine_reaction_notifier/reaction_patch'
require_relative 'lib/redmine_reaction_notifier/hooks'
require_relative 'lib/redmine_reaction_notifier/user_preference_patch'

Redmine::Plugin.register :redmine_reaction_notifier do
  name 'Redmine Reaction Notifier'
  author 'sk-ys'
  description 'Sends email notifications to the author when reactions are added'
  version '0.2.1'
  url 'https://github.com/sk-ys/redmine_reaction_notifier'
  author_url 'https://github.com/sk-ys'
  requires_redmine version_or_higher: '6.1.0'
end

Rails.configuration.after_initialize do
  unless Reaction.included_modules.include?(RedmineReactionNotifier::ReactionPatch)
    Reaction.include(RedmineReactionNotifier::ReactionPatch)
  end
  unless UserPreference.included_modules.include?(RedmineReactionNotifier::UserPreferencePatch)
    UserPreference.include(RedmineReactionNotifier::UserPreferencePatch)
  end
end
