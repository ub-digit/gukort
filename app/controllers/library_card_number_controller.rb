class LibraryCardNumberController < ApplicationController
  def getNumber
    # read personalnumber param
    _pnr = params["pnr"]
    
    # set existing librarycardnumbers for personalnumber to deleted
    Patron.where(personalnumber: _pnr, deleted: nil).each do |patron|
      patron.update(deleted: true)
    end
    
    #Create new patron
    _patron = Patron.new
    _patron.personalnumber = _pnr
    _nr = generate_number();
    #check if generated number exists in database
    while Patron.where(library_cardnumber: _nr).size > 0 do
      _nr = generate_number();
    end

    _patron.library_cardnumber = _nr
    _patron.save
    
    #return result json
    _res = {:personalnumber => _pnr, :librarycardnumber => _patron.library_cardnumber}
    render json: _res
  end

  def generate_number
      return "8" + SecureRandom.random_number.to_s[2..10]
  end
end


