# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_rails-2.3.4-xss_foliate_session',
  :secret      => 'bb27d0cf593fcf34fe56ac0e8578d6b2cd883e2d192e170bc387e8850a08fbd847062d058ed5e394a90e84d9fb181435af3cbc28902821d44da3d6a6b319ce20'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
