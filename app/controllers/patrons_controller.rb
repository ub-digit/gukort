class PatronsController < BaseController
  def new
    message = Message.save_message request.body.read
    if !message.parse_message
      update_attributes({exit_message: "Parse error #{__FILE__}:#{__LINE__}"})
      render_response(original_type: 'NEW', error: true, error_code: '400')
      return
    end
    render_response(original_type: 'NEW')
    message.handle_new
  end

  def card
    message = Message.save_message request.body.read
    if !message.parse_message
      update_attributes({exit_message: "Parse error #{__FILE__}:#{__LINE__}"})
      render_response(original_type: 'UPDATE CARD', error: true, error_code: '400')
      return
    end
    render_response(original_type: 'UPDATE CARD')
    message.handle_card
  end

  def pnr
    message = Message.save_message request.body.read
    if !message.parse_message
      update_attributes({exit_message: "Parse error #{__FILE__}:#{__LINE__}"})
      render_response(original_type: 'UPDATE PNR', error: true, error_code: '400')
      return
    end
    render_response(original_type: 'UPDATE PNR')
    message.handle_pnr
  end
end
