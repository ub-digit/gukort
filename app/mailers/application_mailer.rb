class ApplicationMailer < ActionMailer::Base
  default from: APP_CONFIG['mail_settings']['from_email']
  default to: APP_CONFIG['mail_settings']['to_email']

  def no_category(cardnumber:, personalnumber:, surname:, firstname:)
    subject_prefix = APP_CONFIG['mail_settings']['subject_prefix'].present? ? APP_CONFIG['mail_settings']['subject_prefix'] : ''
    @subject = "#{subject_prefix}GUKORT - kategori kan inte matchas"
    @cardnumber = cardnumber
    @personalnumber = personalnumber
    @surname = surname
    @firstname = firstname
    delivery_options = {address: APP_CONFIG['mail_settings']['delivery_options']['address'],
                        port: APP_CONFIG['mail_settings']['delivery_options']['port']}

    mail(subject: @subject, delivery_method_options: delivery_options)
  end
end
