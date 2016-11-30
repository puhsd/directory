json.array!(@users) do |user|
  if (current_user)
    json.extract! user, :id, :friendly_id, :displayname, :mail, :ipphone, :site, :title, :imagefile, :link
  else
    json.extract! user, :friendly_id, :displayname, :mail, :ipphone, :site, :title, :imagefile, :link
  end
  # json.url user_url(user, format: :json)
  json.url user_url(user)
end
