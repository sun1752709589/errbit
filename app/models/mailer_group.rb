class MailerGroup
  include Mongoid::Document
  include Mongoid::Timestamps

  field :user_ids, type: Array, default: []
  field :name

  def all_emails
    emails = []
    user_ids.each do |uid|
      emails << User.where(id: uid).to_a.first.try(:email)
    end
    emails.compact.uniq
  end
end