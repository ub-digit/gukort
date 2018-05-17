namespace :messages do
  desc "Check canceled cards and update member in Koha"
  task :check_canceled => :environment do
    Message.recently_canceled.each do |message|
      message.check_canceled
    end
  end
end