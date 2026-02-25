module RedmineReactionNotifier
  module ReactionPatch
    extend ActiveSupport::Concern

    included do
      after_create :notify_reaction_added
    end

    def reactable_author
      case reactable
      when Issue       then reactable.author
      when Journal     then reactable.user
      when Message     then reactable.author
      when News        then reactable.author
      when WikiContent then reactable.author
      end
    end

    private

    def notify_reaction_added
      author = reactable_author
      return if author.nil?
      return if author == user
      return unless author.active?
      return if author.mail.blank?

      ReactionNotifierMailer.reaction_added(User.current, self).deliver_later
    rescue StandardError => e
      Rails.logger.error "ReactionNotifier: failed to send notification - #{e.message}"
    end
  end
end
