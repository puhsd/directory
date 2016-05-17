json.array!(@users) do |user|
  json.extract! user, :displayname, :mail, :ipphone, :site, :title
  # json.url user_url(user, format: :json)
  json.url user_url(user)
end
