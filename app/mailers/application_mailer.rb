class ApplicationMailer < ActionMailer::Base
  default from: ENV['GMAIL_SENDER_EMAIL']
  layout 'mailer'
end
