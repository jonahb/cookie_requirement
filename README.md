CookieRequirement
=================

CookieRequirement verifies that cookies are enabled in a Rails app. Include
the module in a controller, and declare the actions that require cookies with
the `cookies_required` class method.

Example
-------

    class UserController

      include CookieRequirement

      cookies_required :login

      # if login is accessed without cookies, handle_cookies_disabled is called
      def login
      end

      def cookie_instructions
        # show some instructions
      end

    protected

      # override the default behavior to display instructions
      def handle_cookies_diabled
        redirect_to :action => "cookie_instructions"
      end

    end

How It Works
------------

CookieRequirement adds a before_filter to the controller in which it is
included. This filter checks if the invoked action requires cookies. If so,
it sets a test cookie and redirects to the same action, adding a query
parameter to indicate that a test cookie should exist. If the cookie does
not exist after the redirection, CookieRequirement concludes that cookies
are disabled and calls `handle_cookies_disabled`, which, by default, raises
`CookieRequirement::CookiesDisabled`.

Note: CookieRequirement adds the before_filter when it is included.  If you
want other before_filters to run before CookieRequirement, declare them
before including CookieRequirement.

Acknowledgments
---------------

CookieRequirement is based on:

* Blog post by James Halberg: http://jameshalberg.wordpress.com/2006/05/12/requiring-and-testing-cookies/
* SSL Requirement David Heinemeier Hansson: http://dev.rubyonrails.org/svn/rails/plugins/ssl_requirement/
