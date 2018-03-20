class PatronsController < BaseController
  def new
    message = Message.save_message request.body.read
    begin
      if !message.parse_message
        message.update_attributes({exit_message: "Parse error #{__FILE__}:#{__LINE__}"})
        render_response(original_type: 'NEW', error: true, error_code: '400')
        return
      end
      render_response(original_type: 'NEW')
      message.handle_new
    rescue StandardError => error
      message.update_attributes({exit_message: "Exception: #{error.inspect} #{__FILE__}:#{__LINE__}: #{error.backtrace.join(" ")}"})
    end
  end

  def card
    message = Message.save_message request.body.read
    begin
      if !message.parse_message
        message.update_attributes({exit_message: "Parse error #{__FILE__}:#{__LINE__}"})
        render_response(original_type: 'UPDATE CARD', error: true, error_code: '400')
        return
      end
      render_response(original_type: 'UPDATE CARD')
      message.handle_card
    rescue StandardError => error
      message.update_attributes({exit_message: "Exception: #{error.inspect} #{__FILE__}:#{__LINE__}: #{error.backtrace.join(" ")}"})
    end
  end

  def pnr
    message = Message.save_message request.body.read
    begin
      if !message.parse_message
        message.update_attributes({exit_message: "Parse error #{__FILE__}:#{__LINE__}"})
        render_response(original_type: 'UPDATE PNR', error: true, error_code: '400')
        return
      end
      render_response(original_type: 'UPDATE PNR')
      message.handle_pnr
    rescue StandardError => error
      message.update_attributes({exit_message: "Exception: #{error.inspect} #{__FILE__}:#{__LINE__}: #{error.backtrace.join(" ")}"})
    end
  end
end
