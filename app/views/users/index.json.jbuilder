json.array!(@users) do |user|
  if (current_user)
    json.extract! user, :id, :displayname, :mail, :ipphone, :site, :title, :imagefile
  else
    json.extract! user, :displayname, :mail, :ipphone, :site, :title, :imagefile
  end
  # json.url user_url(user, format: :json)
  json.url user_url(user)
end
