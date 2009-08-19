# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_loofah-test-app_session',
  :secret      => '051aae5a8c40707a35fb8b622d0d3226aa2679dbd0c50030857309645ba5cbab382a85bf3d8b7f8c8e8885d5f929f339d20897b74bc64ecbc79f43bb795a398a'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
