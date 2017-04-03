json.array!(@users) do |user|
  json.extract! user, :displayname, :mail, :ipphone, :site, :title, :imagefile
end
