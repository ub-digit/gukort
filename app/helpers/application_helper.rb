module ApplicationHelper
  def handle_personalnumber raw_number
    return nil if raw_number.blank?
    return raw_number if raw_number.length.eql?(12)
    return "20" + raw_number if raw_number.length.eql?(10) && /^[0]/.match(raw_number)
    return "19" + raw_number if raw_number.length.eql?(10) && /^[^0]/.match(raw_number)
    return nil
  end
end
