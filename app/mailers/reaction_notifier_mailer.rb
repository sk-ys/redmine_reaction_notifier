class ReactionNotifierMailer < Mailer
  def reaction_added(author, reaction)
    @author           = author # Used as display name in the email 'From' field
    @reaction         = reaction
    @reactor          = reaction.user
    @reactable        = reaction.reactable
    @reactable_author = reaction.reactable_author
    @reactable_url    = reactable_url(@reactable)
    @reactable_type   = reactable_type_name(@reactable)
    @reactable_title  = reactable_title(@reactable)
    @reactable_summary = reactable_summary(@reactable)

    mail(
      to:      reaction.reactable_author,
      subject: "[#{Setting.app_title}] #{l(:mail_subject_reaction_added, reactor: @reactor.name)}"
    )
  end

  private

  def reactable_type_name(reactable)
    case reactable
    when Journal
      l(:field_notes)
    else
      reactable.class.model_name.human
    end
  rescue StandardError
    reactable.class.name
  end

  def get_journal_indice(journal)
    journal.indice || journal.issue.visible_journals_with_index.find{|j| j.id == journal.id}.indice
  end

  def reactable_title(reactable)
    case reactable
    when Issue
      "##{reactable.id} #{reactable.subject}"
    when Journal
      issue = reactable.journalized if reactable.respond_to?(:journalized)
      if issue.is_a?(Issue)
        note_id = get_journal_indice(reactable)
        "##{issue.id} #{issue.subject}" + (note_id ? " #note-#{note_id}" : " #change-#{reactable.id}")
      end
    when Message
      reactable.subject
    when News
      reactable.title
    when WikiContent
      reactable.page&.pretty_title || reactable.page&.title
    end
  end

  def reactable_summary(reactable)
    case reactable
    when Issue
      reactable.description
    when Journal
      reactable.notes
    when Message
      reactable.respond_to?(:content) ? reactable.content : nil
    when News
      reactable.summary.presence || reactable.description
    when WikiContent
      reactable.text
    end
  end

  def reactable_url(reactable)
    case reactable
    when Issue
      issue_url(reactable)
    when Journal
      issue_url(reactable.journalized, anchor: "change-#{reactable.id}")
    when Message
      board_message_url(reactable.board, reactable)
    when News
      news_url(reactable)
    when WikiContent
      project_wiki_page_url(reactable.page.project, reactable.page.title)
    end
  end
end
