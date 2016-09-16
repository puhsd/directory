json.array!(@titles) do |title|
  json.extract! title, :id, :name, :public
  json.url title_url(title, format: :json)
end
