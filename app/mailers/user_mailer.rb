class UserMailer < ApplicationMailer

  def welcome_email
  mail(to: 'syf@huantengsmart.com',
       body: 'hehe',
       content_type: "text/html",
       subject: "sun hehe")
  end
end
