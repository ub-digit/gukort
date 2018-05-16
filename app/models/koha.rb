class Koha
  def self.get_borrowernumber(personalnumber)
    config = get_config
    params = {userid: config[:user], password: config[:password], personalnumber: personalnumber}.to_query
    url = "#{config[:base_url]}/members/check?#{params}"
    response = RestClient.get(url)
    if (response && response.code == 200)
      xml = Nokogiri::XML(response.body).remove_namespaces!
      if xml.search('//response/borrowernumber').text.present?
        return xml.search('//response/borrowernumber').text
      else
        return nil
      end
    else
      return nil
    end
  end

  def self.add(parameter_list)
    config = get_config
    url = "#{config[:base_url]}/members/create"
    response = RestClient.post(url, parameter_list.merge({userid: config[:user], password: config[:password]}))
    if response && (response.code == 200 || response.code == 201)
      return true
    else
      return false
    end
  end

  def self.update(borrowernumber, cardnumber, category, categorycode)
    config = get_config
    url = "#{config[:base_url]}/members/update"
    parameter_list = {action: 'update', borrowernumber: borrowernumber, cardnumber: cardnumber, category: category, categorycode: categorycode}
    response = RestClient.post(url, parameter_list.merge({userid: config[:user], password: config[:password]}))
    if response && (response.code == 200 || response.code == 201)
      return true
    else
      return false
    end
  end

  def self.update_pnr(borrowernumber, personalnumber)
    config = get_config
    url = "#{config[:base_url]}/members/update"
    parameter_list = {action: 'pnr', borrowernumber: borrowernumber, personalnumber: personalnumber}
    response = RestClient.post(url, parameter_list.merge({userid: config[:user], password: config[:password]}))
    if response && (response.code == 200 || response.code == 201)
      return true
    else
      return false
    end
  end

  def self.card_invalid(borrowernumber)
    config = get_config
    url = "#{config[:base_url]}/members/update"
    parameter_list = {action: 'cardinvalid', borrowernumber: borrowernumber}
    response = RestClient.post(url, parameter_list.merge({userid: config[:user], password: config[:password]}))
    if response && (response.code == 200 || response.code == 201)
      return true
    else
      return false
    end
  end

  def self.card_valid(borrowernumber)
    config = get_config
    url = "#{config[:base_url]}/members/update"
    parameter_list = {action: 'cardvalid', borrowernumber: borrowernumber}
    response = RestClient.post(url, parameter_list.merge({userid: config[:user], password: config[:password]}))
    if response && (response.code == 200 || response.code == 201)
      return true
    else
      return false
    end
  end

  def self.get_config
    {
      base_url: APP_CONFIG['koha']['base_url'],
      user: APP_CONFIG['koha']['user'],
      password: APP_CONFIG['koha']['password']
    }
  end
end