# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_rails-2.3.4-ar_scrub_session',
  :secret      => 'cdce537e48918cf6af094241d1be693ee2c3e006d47767bf41363727102c62829a9b7aa80c38e4c22d15b76dafbcb7a1a9f5258fa0a8e6a637936e535f7a016c'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
