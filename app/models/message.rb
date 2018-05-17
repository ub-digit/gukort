class Message < ApplicationRecord

  scope :recently_canceled, -> { where(message_type: "UPDATECARDINVALID").where(status: "WAITING").where('updated_at < ?', 30.minutes.ago) }

  def self.save_message message
    create(raw_message: message, status: "NEW")
  end

  def validate_message
    update_attributes({status: "VALIDATED"})
  end

  def parse_message
    xml = create_xml_object raw_message
    attr_data = {
      originated_at: (parse_originated_at xml),
      message_source: (parse_message_source xml),
      message_type: (parse_message_type xml),
      message_category: (parse_message_category xml),
      categorycode: (parse_categorycode xml),
      personalnumber: (parse_personalnumber xml),
      old_personalnumber: (parse_old_personalnumber xml),
      cardnumber: (parse_cardnumber xml),
      pincode: (parse_pincode xml),
      valid_info: (parse_valid_info xml),
      valid_to: (parse_valid_to xml),
      invalid_reason: (parse_invalid_reason xml),
      surname: (parse_surname xml),
      firstname: (parse_firstname xml),
      co: (parse_co xml),
      address: (parse_address xml),
      zipcode: (parse_zipcode xml),
      city: (parse_city xml),
      country: (parse_country xml),
      temp_co: (parse_temp_co xml),
      temp_address: (parse_temp_address xml),
      temp_zipcode: (parse_temp_zipcode xml),
      temp_city: (parse_temp_city xml),
      temp_country: (parse_temp_country xml),
      temp_from: (parse_temp_from xml),
      temp_to: (parse_temp_from xml),
      phone: (parse_phone xml),
      email: (parse_email xml),
      userid: (parse_userid xml)
    }

    update_attributes(attr_data)
    update_attributes({status: "PARSED"})

    return true
  end

  def create_xml_object message
    Nokogiri::XML(message).remove_namespaces!
  end

  def parse_originated_at xml
    xml.search('GUKORT_UB/datetime').text
  end

  def parse_message_source xml
    data = xml.search('GUKORT_UB/source').text
    if data.present?
      return data
    else
      return xml.search('GUKORT_UB/person/source').text
    end
  end

  def parse_message_type xml
    data = xml.search('GUKORT_UB/type').text
    if data.present?
      return data
    else
      return xml.search('GUKORT_UB/person/type').text
    end
  end

  def parse_message_category xml
    data = xml.search('GUKORT_UB/category').text
    if data.present?
      return data
    else
      return xml.search('GUKORT_UB/person/category').text
    end
  end

  def parse_categorycode xml
    faculty = xml.search('GUKORT_UB/membership/group[@type="faculty"]/id').text
    department = xml.search('GUKORT_UB/membership/group[@type="institution"]/id').text
    category_code_mapping faculty, department
  end

  def parse_personalnumber xml
    xml.search('GUKORT_UB/person/pnr').text
  end

  def parse_old_personalnumber xml
    xml.search('GUKORT_UB/person/pnr/@old_pnr').text
  end

  def parse_cardnumber xml
    xml.search('GUKORT_UB/person/card/cardNumber').text
  end

  def parse_pincode xml
    xml.search('GUKORT_UB/person/card/pincode').text
  end

  def parse_valid_info xml
    xml.search('GUKORT_UB/person/card/valid').text
  end

  def parse_valid_to xml
    xml.search('GUKORT_UB/person/card/validTo').text
  end

  def parse_invalid_reason xml
    xml.search('GUKORT_UB/person/card/reason').text
  end

  def parse_surname xml
    xml.search('GUKORT_UB/person/name/surname').text
  end

  def parse_firstname xml
    xml.search('GUKORT_UB/person/name/givenname').text
  end

  def parse_co xml
    xml.search('GUKORT_UB/person/homeAddress/co').text
  end

  def parse_address xml
    xml.search('GUKORT_UB/person/homeAddress/street').text
  end

  def parse_zipcode xml
    xml.search('GUKORT_UB/person/homeAddress/postalCode').text
  end

  def parse_city xml
    xml.search('GUKORT_UB/person/homeAddress/city').text
  end

  def parse_country xml
    xml.search('GUKORT_UB/person/homeAddress/country').text
  end

  def parse_temp_co xml
    xml.search('GUKORT_UB/person/temporaryAddress/co').text
  end

  def parse_temp_address xml
    xml.search('GUKORT_UB/person/temporaryAddress/street').text
  end

  def parse_temp_zipcode xml
    xml.search('GUKORT_UB/person/temporaryAddress/postalCode').text
  end

  def parse_temp_city xml
    xml.search('GUKORT_UB/person/temporaryAddress/city').text
  end

  def parse_temp_country xml
    xml.search('GUKORT_UB/person/temporaryAddress/country').text
  end

  def parse_temp_from xml
    xml.search('GUKORT_UB/person/temporaryAddress/validFrom').text
  end

  def parse_temp_to xml
    xml.search('GUKORT_UB/person/temporaryAddress/validTo').text
  end

  def parse_phone xml
    xml.search('GUKORT_UB/person/telephone').text
  end

  def parse_email xml
    xml.search('GUKORT_UB/person/mail').text
  end

  def parse_userid xml
    xml.search('GUKORT_UB/person/uid').text
  end

  def category_code_mapping faculty, department = ""
    faculty.upcase!
    department.upcase!
    return "EX" if faculty.eql?("GF")
    return "SE" if faculty.eql?("EN")
    return "SH" if faculty.eql?("HN")
    return "SI" if faculty.eql?("IT")
    return "SM" if faculty.eql?("MN")
    return "SA" if faculty.eql?("KN") && department.eql?("HSM")
    return "SK" if faculty.eql?("KN") && ["FM", "KS", "FO", "VK", "SKD", "AKV"].include?(department)
    return "SN" if faculty.eql?("NN")
    return "SM" if faculty.eql?("ON")
    return "EX" if faculty.eql?("XX")
    return "SM" if faculty.eql?("SA")
    return "SS" if faculty.eql?("SN")
    return "EX" if faculty.eql?("TN")
    return "SL" if faculty.eql?("UFL")
    return "SL" if faculty.eql?("UN")
    return "SM" if faculty.eql?("VN")
    return nil
  end

  def default_category
    "EX"
  end

  def handle_new
    # Check that category is student
    if !message_category.eql?("STUDENT")
      update_attributes({exit_message: "Invalid category #{__FILE__}:#{__LINE__}"})
      return
    end
    # Handle personalnumber according to rules
    personalnumber_12 = handle_personalnumber(personalnumber)
    if personalnumber_12.blank?
      update_attributes({exit_message: "Personalnumber format error #{__FILE__}:#{__LINE__}"})
      return
    end
    # Check if personalnumber exists in Koha
    if borrowernumber = Koha.get_borrowernumber(personalnumber_12)
      # Personalnumber exists in Koha, update existing patron
      if Koha.update(borrowernumber, cardnumber, message_category, categorycode)
        update_attributes({status: "COMPLETED", exit_message: "Koha update success #{__FILE__}:#{__LINE__}"})
      else
        update_attributes({status: "COMPLETED", exit_message: "Koha update error #{__FILE__}:#{__LINE__}"})
      end
      return
    end

    # Fix address according to rules
    address_parameter_list = handle_addresses self

    debarments = []
    # Set GNA if no addresses exists or only temprary address with non-local zip zipcode exist
    debarments.push("gna") if gna_debarment? self
    # If category code is empty set GU debarment
    debarments.push("gu") if categorycode.blank?

    parameter_list = {
      origin: "gukort",
      personalnumber: personalnumber_12,
      cardnumber: cardnumber,
      categorycode: categorycode.present? ? categorycode : default_category,
      branchcode: "44",
      debarments: debarments.join(","),
      surname: surname,
      firstname: firstname,
      phone: phone,
      email: email,
      patronuserid: userid,
      lang: "sv-SE",
      messaging_format: email.present? ? "email" : nil,
      accept_text: "Biblioteksreglerna accepteras"
    }.merge(address_parameter_list)

    # Add member to Koha
    if Koha.add(parameter_list)
      # If category code is empty send email
      if categorycode.blank?
        ApplicationMailer.no_category(cardnumber: cardnumber, personalnumber: personalnumber_12, surname: surname, firstname: firstname).deliver_now
      end

      update_script = APP_CONFIG['external_update']['path']
      if update_script.present?
        # TBD run update script
      end
      update_attributes({status: "COMPLETED", exit_message: "Koha add success #{__FILE__}:#{__LINE__}"})
      return
    else
      update_attributes({exit_message: "Koha add error #{__FILE__}:#{__LINE__}"})
      return
    end
  end

  def handle_card
    # Check that type is UPDATECARDINVALID
    if !message_type.eql?("UPDATECARDINVALID")
      update_attributes({exit_message: "Invalid type #{__FILE__}:#{__LINE__}"})
      return
    end

    # Set status to waiting
    update_attributes({status: "WAITING", exit_message: "Set status to waiting, #{__FILE__}:#{__LINE__}"})
  end

  def check_canceled
    # Check if the card is still canceled
    if GukortAdm.is_canceled?(personalnumber)

      # Handle personalnumber according to rules
      personalnumber_12 = handle_personalnumber(personalnumber)
      if personalnumber_12.blank?
        update_attributes({exit_message: "Personalnumber format error #{__FILE__}:#{__LINE__}"})
        return
      end

      # Get borrowernumber from Koha
      borrowernumber = Koha.get_borrowernumber(personalnumber_12)
      if borrowernumber.blank?
        update_attributes({exit_message: "Borrowernumber does not exist in Koha #{__FILE__}:#{__LINE__}"})
        return
      end

      # Write to Koha
      if Koha.card_invalid(borrowernumber)
        update_attributes({status: "COMPLETED", exit_message: "Koha check canceled success, card canceled #{__FILE__}:#{__LINE__}"})
        return
      else
        update_attributes({exit_message: "Koha check canceled error #{__FILE__}:#{__LINE__}"})
        return
      end
    else
      # Don't update card i Koha
      update_attributes({status: "COMPLETED", exit_message: "Koha check canceled success, no action #{__FILE__}:#{__LINE__}"})
    end
  end


  def handle_pnr
    # Handle personalnumber according to rules
    old_personalnumber_12 = handle_personalnumber(old_personalnumber)
    new_personalnumber_12 = handle_personalnumber(personalnumber)
    if old_personalnumber_12.blank? || new_personalnumber_12.blank?
      update_attributes({exit_message: "Personalnumber format error #{__FILE__}:#{__LINE__}"})
      return
    end

    # Check that new personalnumber not exist in Koha
    if Koha.get_borrowernumber(new_personalnumber_12).present?
      update_attributes({exit_message: "New personalnumber already exists in Koha #{__FILE__}:#{__LINE__}"})
      return
    end

    # Get borrower number for oldpersonalnumber
    borrowernumber = Koha.get_borrowernumber(old_personalnumber_12)
    puts old_personalnumber_12
    if borrowernumber.blank?
      update_attributes({exit_message: "Personalnumber not found in Koha #{__FILE__}:#{__LINE__}"})
      return
    end

    if Koha.update_pnr(borrowernumber, new_personalnumber_12)
      update_attributes({status: "COMPLETED", exit_message: "Koha update pnr success #{__FILE__}:#{__LINE__}"})
      return
    else
      update_attributes({exit_message: "Koha update pnr error #{__FILE__}:#{__LINE__}"})
      return
    end
  end


  private
  def handle_addresses message
    if message.address.blank? && message.temp_address.present? && local_zipcode?(message.temp_zipcode)
      {address: [message.temp_co, message.temp_address].compact.join(" "),
       zipcode: message.temp_zipcode,
       city: message.temp_city,
       country: message.temp_country}
    else
      {address: [message.co, message.address].compact.join(" "),
       zipcode: message.zipcode,
       city: message.city,
       country: message.country,
       b_address: message.temp_address,
       b_zipcode: message.temp_zipcode,
       b_city: message.temp_city,
       b_country: message.temp_country}
    end
  end

  def handle_personalnumber raw_number
    return nil if raw_number.blank?
    return raw_number if raw_number.length.eql?(12)
    return "20" + raw_number if raw_number.length.eql?(10) && /^[0]/.match(raw_number)
    return "19" + raw_number if raw_number.length.eql?(10) && /^[^0]/.match(raw_number)
    return nil
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

end
