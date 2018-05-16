namespace :messages do
  desc "Check canceled cards and update member in Koha"
  task :check_canceled => :environment do
    include ApplicationHelper
    Message.where(message_type: "UPDATECARDINVALID").where(status: "WAITING").where('updated_at < ?', 30.minutes.ago).each do |message|
      if !GukortAdm.is_canceled?(message.personalnumber)

        personalnumber_12 = handle_personalnumber(message.personalnumber)
        if personalnumber_12.blank?
          message.update_attributes({update_message: "Personalnumber format error #{__FILE__}:#{__LINE__}"})
          return
        end

        borrowernumber = Koha.get_borrowernumber(personalnumber_12)
        if borrowernumber.blank?
          message.update_attributes({update_message: "Borrowernumber does not exist in Koha #{__FILE__}:#{__LINE__}"})
          return
        end

        if Koha.card_valid(borrowernumber)
          message.update_attributes({status: "COMPLETED", update_message: "Koha update card success #{__FILE__}:#{__LINE__}"})
        else
          message.update_attributes({update_message: "Koha update card error #{__FILE__}:#{__LINE__}"})
        end
      end
    end
  end
end