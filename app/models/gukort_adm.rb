class GukortAdm
  def self.is_canceled?(personalnumber)
    base_url = APP_CONFIG['gukort_adm']['base_url']
    url = "#{base_url}/canceledCards.php?pnr=#{personalnumber}"
    response = RestClient.get(url)
    if (response && response.code == 200)
      xml = Nokogiri::XML(response.body).remove_namespaces!
      if xml.search('//root/canceledCard').text.present? && xml.search('//root/canceledCard').text.eql?('true')
        return true
      else
        return false
      end
    else
      return nil
    end
  end
end
