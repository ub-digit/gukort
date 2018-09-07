require 'test_helper'

class LibraryCardNumberControllerTest < ActionDispatch::IntegrationTest
  test "should get generate" do
    get library_card_number_generate_url
    assert_response :success
  end

end
