require "uri"

# CookieRequirement is a Rails plugin that lets you ensure that cookies are
# enabled. Include the module in a controller, and declare the actions that
# require cookies with the +cookies_required+ class method.
#
# ==Example
#
#   class UserController
#
#     include CookieRequirement
#
#     cookies_required :login
#
#     # if login is accessed without cookies, handle_cookies_disabled is
#     # called
#     def login
#     end
#
#     def cookie_instructions
#       # show some instructions
#     end
#
#   protected
#
#     # override the default behavior to display instructions
#     def handle_cookies_diabled
#       redirect_to :action => "cookie_instructions"
#     end
#
#   end
#
# ==How It Works
#
# CookieRequirement adds a before_filter to the controller in which it is
# included. This filter checks if the invoked action requires cookies. If so,
# it sets a test cookie and redirects to the same action, adding a query
# parameter to indicate that a test cookie should exist. If the cookie does
# not exist after the redirection, CookieRequirement concludes that cookies
# are disabled and calls +handle_cookies_disabled+, which, by default, raises
# +CookiesDisabled+.
#
# Note: CookieRequirement adds the before_filter when it is included.  If you
# want other before_filters to run before CookieRequirement, declare them
# before including CookieRequirement.
#
# ==Acknowledgments
#
# CookieRequirement is based on
# * Blog post by James Halberg:
#   http://jameshalberg.wordpress.com/2006/05/12/requiring-and-testing-cookies/
# * SSL Requirement David Heinemeier Hansson:
#   http://dev.rubyonrails.org/svn/rails/plugins/ssl_requirement/

module CookieRequirement

  class CookiesDisabled < StandardError
  end

  DEFAULT_TEST_COOKIE_NAME = "test_cookie"
  DEFAULT_TEST_COOKIE_WRITTEN_PARAMETER_NAME = "tcw"

  def self.included(controller)
    controller.extend(ClassMethods)
    controller.before_filter(:ensure_cookies)
  end

  module ClassMethods

    def cookies_required( *actions )
      write_inheritable_array( :cookies_required_actions, actions )
    end
  end

protected

  # Returns whether the invoked action has been declared to require cookies
  # with +cookies_required+. Override to take into account other factors.
  def cookies_required?
    ( self.class.read_inheritable_attribute( :cookies_required_actions ) || [] ).include?( action_name.to_sym )
  end

  # Override to handle disabled cookies in another way.
  def handle_cookies_disabled
    raise CookiesDisabled, "Action #{self.params[ :action ]} in controller #{self.params[ :controller ]} requires cookies"
  end

  # Returns the name of the test cookie, "test_cookie" by default. Override
  # if this name conflicts.
  def get_test_cookie_name
    self.class::DEFAULT_TEST_COOKIE_NAME
  end

  # Returns the name of the parameter added upon redirection to indicate that
  # a test cookie has been written, "tcw" by default (short for test cookie
  # written). Override if this name conflicts.
  def get_test_cookie_written_parameter_name
    self.class::DEFAULT_TEST_COOKIE_WRITTEN_PARAMETER_NAME
  end

private

  def ensure_cookies
    if cookies_required? && !test_cookie_exists?
      if test_cookie_written?
        handle_cookies_disabled
      else
        write_test_cookie
        redirect_to( append_parameter_to_uri( get_full_request_uri, get_test_cookie_written_parameter_name, "1" ) )
      end
    end
  end

  def test_cookie_exists?
    !cookies[ get_test_cookie_name ].nil?
  end

  def test_cookie_written?
    !params[ get_test_cookie_written_parameter_name ].nil?
  end

  def write_test_cookie
    cookies[ get_test_cookie_name ]  = "test"
  end

  def get_full_request_uri
    request.protocol + request.host_with_port + request.request_uri
  end

  def append_parameter_to_uri( uri, name, value )
    new_uri = URI.parse( uri )

    if new_uri.query.nil?
      new_uri.query = ""
    else
      new_uri.query << "&"
    end

    new_uri.query << URI.escape( name ) << "=" << URI.escape( value )
    new_uri.to_s
  end

end