class PatronsController < BaseController

  # PUT
  def new
    message = Message.save_message request.body.read
    if !message.parse_message
      render_response(error: true, error_code: 500, error_name: 'Parse error', error_details: '')
      return
    end

    type = message.message_type
    category = message.message_category

    case type
    when 'NEW'
      case category
      when 'STUDENT'
        new_student message
      when 'STAFF'
        #TDB
      else
        render_response(error: true, error_code: 500, error_name: 'Unknown category', error_details: '')
        return
      end
    when 'UPDATE'
      case category
      when 'STUDENT'
        update_student
      when 'STAFF'
        update_staff
      else
        render_response(error: true, error_code: 500, error_name: 'Unknown category', error_details: '')
        return
      end
    else
      render_response(error: true, error_code: 500, error_name: 'Unknown type', error_details: '')
    end
  end


  def new_staff
    # not used
  end

  def new_student message
    # Handle personalnumber according to rules
    personalnumber_12 = handle_personalnumber(message.personalnumber)
    if personalnumber_12.blank?
      render_response(error: true, error_code: 400, error_name: 'Personalnumber format error', error_details: '')
      return
    end
    # Check that personalnumber not exist in Koha
    if Koha.get_borrowernumber(personalnumber_12)
      render_response(error: true, error_code: 400, error_name: 'Patron already exists', error_details: '')
      return
    end

    # Fix address according to rules
    address_parameter_list = handle_addresses message

    debarments = []
    # Set GNA if no addresses exists or only temprary address with non-local zip zipcode exist
    debarments.push("gna") if gna_debarment?(message)
    # If category code is empty set GU debarment and send email
    debarments.push("")

    parameter_list = {
      origin: "gukort",
      personalnumber: personalnumber_12,
      cardnumber: message.cardnumber,
      categorycode: message.categorycode,
      branchcode: "44",
      debarments: debarments.join(","),
      surname: message.surname,
      firstname: message.firstname,
      phone: message.phone,
      email: message.email,
      messaging_format: message.email.present? ? "email" : nil,
      accept_text: "Biblioteksreglerna accepteras"
    }.merge(address_parameter_list)

    # Add member to Koha
    if Koha.add(parameter_list)
      render_response(original_type: 'NEW')
      return
    else
      render_response(error: true, error_code: 500, error_name: '', error_details: '')
      return
    end
  end

  def update_student
    render_response(error: true, error_code: 500, error_name: '', error_details: '')
  end

  def update_staff
    render_response(error: true, error_code: 500, error_name: '', error_details: '')
  end


  # PUT
  def card
    message = Message.save_message request.body.read
    if !message.parse_message
      render_response(error: true, error_code: 500, error_name: 'Parse error', error_details: '')
      return
    end

    # Handle personalnumber according to rules
    personalnumber_12 = handle_personalnumber(message.old_personalnumber)

    if personalnumber_12.blank?
      render_response(error: true, error_code: 400, error_name: 'Personalnumber format error', error_details: '')
      return
    end

    # Get borrowernumber from Koha
    borrowernumber = Koha.get_borrowernumber(personalnumber_12).present?
    if !borrowernumber
      render_response(error: true, error_code: 400, error_name: 'Borrowernumber does not exist in Koha', error_details: '')
      return
    end


    type = message.message_type

    puts "The type is #{type}!!!!!!!!"

    case type
    when 'UPDATECARDINVALID'
      update_card_invalid borrowernumber
    when 'UPDATEVALIDPERIOD'
      #TDB
    when 'CHANGEPIN'
      #TDB
    else
      render_response(error: true, error_code: 500, error_name: 'Unknown type', error_details: '')
    end
  end

  def update_card_invalid borrowernumber
    if Koha.cardinvalid(borrowernumber)
      render_response(original_type: 'UPDATE PNR')
      return
    else
      render_response(error: true, error_code: 500, error_name: '', error_details: '')
      return
    end
  end

  def update_pnr
    message = Message.save_message request.body.read
    if !message.parse_message
      render_response(error: true, error_code: 500, error_name: 'Parse error', error_details: '')
      return
    end

    # Handle personalnumber according to rules
    old_personalnumber_12 = handle_personalnumber(message.old_personalnumber)
    new_personalnumber_12 = handle_personalnumber(message.personalnumber)

    if old_personalnumber_12.blank? || new_personalnumber_12.blank?
      render_response(error: true, error_code: 400, error_name: 'Personalnumber format error', error_details: '')
      return
    end

    # Check that new personalnumber not exist in Koha
    if Koha.get_borrowernumber(new_personalnumber_12).present?
      render_response(error: true, error_code: 400, error_name: 'New personalnumber already exists in Koha', error_details: '')
      return
    end

    # Get borrower number for oldpersonalnumber
    borrowernumber = Koha.get_borrowernumber(old_personalnumber_12)
    puts old_personalnumber_12
    if borrowernumber.blank?
      render_response(error: true, error_code: 400, error_name: 'Personalnumber not found in Koha', error_details: '')
      return
    end

    if Koha.update_pnr(borrowernumber, new_personalnumber_12)
      render_response(original_type: 'UPDATE PNR')
      return
    else
      render_response(error: true, error_code: 500, error_name: '', error_details: '')
      return
    end
  end

private
  def handle_addresses message
    if message.address.blank? && message.temp_address.present? && local_zipcode?(message.temp_zipcode)
      {address: message.temp_address,
       zipcode: message.temp_zipcode,
       city: message.temp_city,
       country: message.temp_country
      }
    else
      {address: message.address,
       zipcode: message.zipcode,
       city: message.city,
       country: message.country,
       b_address: message.temp_address,
       b_zipcode: message.temp_zipcode,
       b_city: message.temp_city,
       b_country: message.temp_country
      }
    end
  end

  def gna_debarment? message
    return true if message.address.blank? && message.temp_address.blank?
    return true if message.temp_address.present? && !local_zipcode?(message.temp_zipcode)
    false
  end

  def local_zipcode? code
    return true if code.present? && code.length.eql?(5) && code.start_with?("4") && !code.eql?("40530")
    false
  end

  def handle_personalnumber raw_number
    return nil if raw_number.blank?
    return raw_number if raw_number.length.eql?(12)
    return "20" + raw_number if raw_number.length.eql?(10) && /^[0]/.match(raw_number)
    return "19" + raw_number if raw_number.length.eql?(10) && /^[^0]/.match(raw_number)
    return nil
  end
end
