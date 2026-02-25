class ReactionNotifierMailer < Mailer
  def reaction_added(author, reaction)
    @author           = author # Used as display name in the email 'From' field
    @reaction         = reaction
    @reactor          = reaction.user
    @reactable        = reaction.reactable
    @reactable_author = reaction.reactable_author
    @reactable_url    = reactable_url(@reactable)

    mail(
      to:      reaction.reactable_author,
      subject: "[#{Setting.app_title}] #{l(:mail_subject_reaction_added, reactor: @reactor.name)}"
    )
  end

  private

  def reactable_url(reactable)
    case reactable
    when Issue
      issue_url(reactable)
    when Journal
      issue_url(reactable.journalized, anchor: "note-#{reactable.id}")
    when Message
      board_message_url(reactable.board, reactable)
    when News
      news_url(reactable)
    when WikiContent
      project_wiki_page_url(reactable.page.project, reactable.page.title)
    end
  end
end
