# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_rails-2.3.4-no-ar_session',
  :secret      => '81661b68d45ec984e980ec8915121c96b01a6024c7cfc6eaf02421c5df215a0e96842fb56b24dbaaa454e971f8946b8f2c65427b4043e5f055928adc864a5750'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
