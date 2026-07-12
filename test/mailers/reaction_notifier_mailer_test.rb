require File.expand_path('../../test_helper', __FILE__)

class ReactionNotifierMailerTest < ActionMailer::TestCase
  fixtures :users, :email_addresses, :issues, :journals, :projects,
           :trackers, :issue_statuses, :enumerations

  setup do
    Setting.host_name   = 'localhost'
    Setting.protocol    = 'http'
    Setting.app_title   = 'Redmine'
    Setting.mail_from   = 'redmine@example.com'
    ActionMailer::Base.deliveries.clear
    # Clean up reactions to avoid unique constraint errors between test runs
    Reaction.delete_all
  end

  teardown do
    # Ensure all reactions are cleaned up after each test
    Reaction.delete_all
  end

  # ------------------------------------------------------------------
  # reaction_added
  # ------------------------------------------------------------------

  test 'reaction_added for an issue sends mail to the issue author' do
    reactor = users(:users_002)   # jsmith
    author  = users(:users_003)   # dlopper
    issue   = issues(:issues_001)
    issue.update_column(:author_id, author.id)

    reaction = build_reaction(reactor, issue)

    mail = ReactionNotifierMailer.reaction_added(author, reaction)

    assert_equal [author.mail], mail.to
    assert_match reactor.name, mail.subject
    assert_match reactor.name, mail.body.encoded
    assert_match issue.subject, mail.body.encoded
    assert_match issue.description.to_s[0, 10], mail.body.encoded
  end

  test 'reaction_added for a journal sends mail to the journal user' do
    reactor = users(:users_002)
    author  = users(:users_003)
    journal = journals(:journals_001)
    journal.update_column(:user_id, author.id)

    reaction = build_reaction(reactor, journal)

    mail = ReactionNotifierMailer.reaction_added(author, reaction)

    assert_equal [author.mail], mail.to
    assert_match reactor.name, mail.subject
    assert_match journal.journalized.subject, mail.body.encoded
  end

  # ------------------------------------------------------------------
  # ReactionPatch – notify_reaction_added
  # ------------------------------------------------------------------

  test 'notify_reaction_added enqueues mail when reactor differs from author' do
    reactor = users(:users_002)
    author  = users(:users_003)
    issue   = issues(:issues_001)
    issue.update_column(:author_id, author.id)

    reaction = create_reaction(reactor, issue)
    ActionMailer::Base.deliveries.clear

    assert_emails 1 do
      reaction.send(:notify_reaction_added)
    end
  end

  test 'notify_reaction_added does not enqueue mail when reactor is the author' do
    user  = users(:users_002)
    issue = issues(:issues_001)
    issue.update_column(:author_id, user.id)

    reaction = build_reaction(user, issue)
    assert_emails 0 do
      reaction.send(:notify_reaction_added)
    end
  end

  test 'notify_reaction_added does not enqueue mail when author is nil' do
    reactor = users(:users_002)
    # Reactable is nil, so reactable_author is nil and no email is sent.
    reaction = build_reaction(reactor, nil)
    assert_emails 0 do
      reaction.send(:notify_reaction_added)
    end
  end

  test 'notify_reaction_added does not enqueue mail when author is inactive' do
    reactor = users(:users_002)
    author  = users(:users_003)
    issue   = issues(:issues_001)
    issue.update_column(:author_id, author.id)
    author.update_column(:status, User::STATUS_LOCKED)

    reaction = build_reaction(reactor, issue)
    assert_emails 0 do
      reaction.send(:notify_reaction_added)
    end
  ensure
    author.update_column(:status, User::STATUS_ACTIVE)
  end

  test 'notify_reaction_added does not enqueue mail when author disabled notifications' do
    reactor = users(:users_002)
    author  = users(:users_003)
    issue   = issues(:issues_001)
    issue.update_column(:author_id, author.id)

    # Disable notification
    author.pref[:reaction_notification] = '0'
    author.pref.save

    reaction = build_reaction(reactor, issue)
    assert_emails 0 do
      reaction.send(:notify_reaction_added)
    end
  ensure
    # Reset to default (enabled)
    author.pref.others.delete(:reaction_notification)
    author.pref.others.delete('reaction_notification')
    author.pref.save
  end

  test 'notify_reaction_added enqueues mail when author notification preference is not set (default)' do
    reactor = users(:users_002)
    author  = users(:users_003)
    issue   = issues(:issues_002)
    issue.update_column(:author_id, author.id)

    # Ensure default (enabled) by removing any existing preference
    author.pref.others.delete(:reaction_notification)
    author.pref.others.delete('reaction_notification')
    author.pref.save

    reaction = create_reaction(reactor, issue)
    ActionMailer::Base.deliveries.clear

    assert_emails 1 do
      reaction.send(:notify_reaction_added)
    end
  end

  private

  # Build a Reaction-like object without touching the database.
  def build_reaction(reactor, reactable)
    reaction = Reaction.new
    reaction.user      = reactor
    reaction.reactable = reactable
    reaction
  end

  def create_reaction(reactor, reactable)
    Reaction.create!(user: reactor, reactable: reactable)
  end
end
