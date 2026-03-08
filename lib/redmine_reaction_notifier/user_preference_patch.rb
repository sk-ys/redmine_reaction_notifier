module RedmineReactionNotifier
  module UserPreferencePatch
    def self.included(base)
      base.safe_attributes('reaction_notification')
    end

    # Default is enabled when no preference exists.
    def reaction_notification
      return false if self[:reaction_notification] == false
      true
    end

    def reaction_notification=(value)
      self[:reaction_notification] = ActiveModel::Type::Boolean.new.cast(value)
    end
  end
end
