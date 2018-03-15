class BaseController < ApplicationController
  skip_before_action :verify_authenticity_token

  def render_response(original_type:'UNKNOWN', error:false, error_code:'', error_name:'', error_details:'')
    time = Time.now
    ref = "#{time.strftime("%Y-%m-%d-%H-%M-%S")}-#{time.usec}"

    if error
      status = 400
      name = "ERROR"
      text = "The request resulted in an error. If You are going to contact GUB for furhter investigation of this error, please use the reference and datetime given in this response."
    else
      status = 201
      name = "RECIEVED"
      text = "The request was successfully recieved and understood. It now awaits further processing by other systems at GUB."
    end

    builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
      xml.GUKORT_UB(version: '1.0') {
        xml.datetime "#{time.strftime("%Y-%m-%d %H:%M:%S")}"
        xml.serverMessages {
          xml.name "#{name}"
          xml.text "#{text}"
          xml.originalType "#{original_type}"
          xml.reference "#{ref}"
          if error
            xml.error {
              xml.errorCode "#{error_code}"
              xml.errorName "#{error_name}"
              xml.errorDetails "#{error_details}"
            }
          end
        }
      }
    end
    puts builder.to_xml
    render status: status, xml: builder.to_xml
  end

end
