require "rubygems"
require "action_controller"
require "action_controller/test_process"
require "test/unit"

require File.dirname( __FILE__ ) + "/../lib/cookie_requirement"

ActionController::Routing::Routes.reload rescue nil

class CookieRequirementController < ActionController::Base

  include CookieRequirement

  cookies_required :required

  def not_required
    render :nothing => true
  end

  def required
    render :nothing => true
  end

  def rescue_action( exception )
    if exception.is_a?( CookiesDisabled )
      @cookies_disabled = true
      render :nothing => true
    end
  end
end

class CookieRequrementWithCustomHandlingController < ActionController::Base

  include CookieRequirement

  cookies_required :required

  def handle_cookies_disabled
    @cookies_disabled = true
    render :nothing => true
  end
end

class CookieRequirementTest < ActionController::TestCase

  def setup
    @controller = CookieRequirementController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new  
  end

  def test_not_required
    get :not_required
    assert_response :success
  end

  def test_required_first_request
    get :required
    assert_response :redirect
    assert_equal( "http://test.host/cookie_requirement/required?tcw=1", @response.headers[ "Location" ] )
    assert_equal( "test", @response.cookies[ "test_cookie" ] )
  end

  def test_required_first_request_with_querystring
    get :required, { :foo => "bar" }
    assert_response :redirect
    assert_equal( "http://test.host/cookie_requirement/required?foo=bar&tcw=1", @response.headers[ "Location" ] )
  end  

  def test_required_second_request_cookies_enabled
    @request.cookies[ "test_cookie" ] = CGI::Cookie.new( "test_cookie", "test" )
    get :required, { :tcw => "1" }
    assert_response :success
  end

  def test_required_second_request_cookies_disabled
    get :required, { :tcw => "1" }
    assert_response :success
    assert( assigns[ "cookies_disabled" ] )
  end

  def test_custom_cookies_disabled_handling
    @controller = CookieRequrementWithCustomHandlingController.new
    get :required, { :tcw => "1" }
    assert_response :success
    assert( assigns[ "cookies_disabled" ] )
  end

end
