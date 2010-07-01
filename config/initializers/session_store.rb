# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_Uploader_session',
  :secret      => 'c595f9e16d1df1f776dbb8987595830051078f5b02b3a3b5dd2b249a7dc9f1185123eb82e40d14897e66779732431848498ae83992be53a5979c82e28fb14213'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
