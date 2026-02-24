class ReactionNotifierMailer < Mailer
  def reaction_added(reaction)
    @reaction       = reaction
    @reactor        = reaction.user
    @reactable      = reaction.reactable
    @author         = reaction.reactable_author
    @reactable_url  = reactable_url(@reactable)

    set_language_if_valid(@author.language.presence || Setting.default_language)

    mail(
      to:      @author.mail,
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
