class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  #layout :determine_layout
  layout 'blacklight'

  protect_from_forgery with: :exception
end
