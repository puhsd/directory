class Title < ApplicationRecord

  validates :name, uniqueness: true

  def self.extract
      user_titles = User.pluck(:ldap_attributes).map{|j| j['title'].split(',') }.flatten.uniq
      titles = Title.pluck(:name)


      add = user_titles - titles

      add.each do |title|
        Title.new(name: title).save
        # puts title
      end
  end

end
