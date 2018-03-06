class Message < ApplicationRecord
  def self.save_message message
    create(raw_message: message, status: "NEW")
  end

  def parse_message
    # validate xml first, TBD
    update_attributes({status: "VALIDATED"})
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
    faculty = xml.search('GUKORT_UB/membership/group[@type="FAKULTET"]/id').text
    department = xml.search('GUKORT_UB/membership/group[@type="INSTITUTION"]/id').text
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

end
