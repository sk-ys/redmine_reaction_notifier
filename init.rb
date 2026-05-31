if Rails.env.production?
  require_relative 'lib/redmine_reaction_notifier/reaction_patch'
  require_relative 'lib/redmine_reaction_notifier/user_preference_patch'
  require_relative 'lib/redmine_reaction_notifier/hooks'
else
  unless defined?(RedmineReactionNotifier::ReactionPatch)
    load File.expand_path('lib/redmine_reaction_notifier/reaction_patch.rb', __dir__)
  end
  unless defined?(RedmineReactionNotifier::UserPreferencePatch)
    load File.expand_path('lib/redmine_reaction_notifier/user_preference_patch.rb', __dir__)
  end

  # In development, remove existing listeners before reloading hooks to avoid duplicate registrations.
  begin
    listener_classes = Redmine::Hook.class_variable_get(:@@listener_classes)
    removed = listener_classes.reject! { |klass| klass.name == 'RedmineReactionNotifier::Hooks' }
    Redmine::Hook.clear_listeners_instances if removed
  rescue NameError
    # Ignore when hook internals are not initialized yet.
  end
  RedmineReactionNotifier.send(:remove_const, :Hooks) if defined?(RedmineReactionNotifier::Hooks)
  load File.expand_path('lib/redmine_reaction_notifier/hooks.rb', __dir__)
end

Redmine::Plugin.register :redmine_reaction_notifier do
  name 'Redmine Reaction Notifier'
  author 'sk-ys'
  description 'Sends email notifications to the author when reactions are added'
  version '0.2.4'
  url 'https://github.com/sk-ys/redmine_reaction_notifier'
  author_url 'https://github.com/sk-ys'
  requires_redmine version_or_higher: '6.1.0'
end

unless Reaction.included_modules.include?(RedmineReactionNotifier::ReactionPatch)
  Reaction.include(RedmineReactionNotifier::ReactionPatch)
end
unless UserPreference.included_modules.include?(RedmineReactionNotifier::UserPreferencePatch)
  UserPreference.include(RedmineReactionNotifier::UserPreferencePatch)
end
