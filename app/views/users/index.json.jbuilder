json.array!(@users) do |user|
  json.extract! user, :id, :object_guid, :username, :ldap_imported_at, :ldap_attributes
  json.url user_url(user, format: :json)
end
