class User < ActiveRecord::Base
  has_and_belongs_to_many :groups

  extend FriendlyId
  friendly_id :username, use: :slugged
# class User < ApplicationRecord
  enum access_level: { user: 0, manager: 1, admin: 2 }


	LDAP_CONFIG = YAML.load(ERB.new(File.read("#{Rails.root}/config/ldap.yml")).result)[Rails.env]

  LDAP_CONFIG["read-attributes"].each do |key|
    # attr_accessible key

    define_method(key) do
      ldap_attributes && ldap_attributes[key]
    end

    define_method("#{key}=") do |value|
      self.ldap_attributes = (ldap_attributes || {}).merge(key => value)
    end
  end

  ransacker :sn do |parent|
    Arel::Nodes::InfixOperation.new('->', parent.table[:ldap_attributes], Arel::Nodes.build_quoted('sn'))
  end

  ransacker :givenname do |parent|
    Arel::Nodes::InfixOperation.new('->', parent.table[:ldap_attributes], Arel::Nodes.build_quoted('givenname'))
  end

  ransacker :title do |parent|
    Arel::Nodes::InfixOperation.new('->', parent.table[:ldap_attributes], Arel::Nodes.build_quoted('title'))
  end

  ransacker :physicaldeliveryofficename do |parent|
    Arel::Nodes::InfixOperation.new('->', parent.table[:ldap_attributes], Arel::Nodes.build_quoted('physicaldeliveryofficename'))
  end

  def enabled?
    ['512', '544', '66048', '66080', '262656', '262688', '328192', '328224'].include?(useraccountcontrol)
  end

  def disabled?
  	!enabled?
  end

  scope :enabled, -> { where("ldap_attributes @> hstore(?, ?)", "useraccountcontrol", "512") }

  default_scope {enabled}


  def imagefile
     "images/#{self.username}.jpg" if File.file?(Rails.root+"public/images/#{self.username}.jpg")
  end

  def site
      self.physicaldeliveryofficename
  end

  def processimage(tmpfile)
    file = File.join(Rails.root+"public/images","#{self.username}.jpg")
    FileUtils.cp tmpfile.path, file
    File.chmod(0644, file)
  end

  def update_tracked_fields!(request)
    old_current, new_current = self.current_sign_in_at, Time.now.utc
    self.last_sign_in_at     = old_current || new_current
    self.current_sign_in_at  = new_current

    old_current, new_current = self.current_sign_in_ip, request.ip
    self.last_sign_in_ip     = old_current || new_current
    self.current_sign_in_ip  = new_current

    self.sign_in_count ||= 0
    self.sign_in_count += 1

    save(:validate => false) or raise "Could not save or update user's tracked fields #{inspect}."
  end

  def self.ldap_connection(username = nil, password = nil)
    # ldap = Net::LDAP.new
    # ldap.host = LDAP_CONFIG["host"]
    # ldap.port = LDAP_CONFIG["port"]
    # ldap.base = LDAP_CONFIG["base"]
    # ldap.encryption LDAP_CONFIG["encryption"]
    # if username && password
    #   ldap.auth "#{username}@puhsd.org", password
    # else
    #   ldap.auth LDAP_CONFIG["admin_username"], LDAP_CONFIG["admin_password"]
    # end
    # return ldap
    ldap = Net::LDAP.new(:host => LDAP_CONFIG["host"],
                     :port => LDAP_CONFIG["port"],
                     :encryption => { :method => :simple_tls },
                     :base =>  LDAP_CONFIG["base"],
                     :auth => {
                        :method => :simple,
                        :username => LDAP_CONFIG["admin_username"],
                        :password => LDAP_CONFIG["admin_password"]
                      })
  end

  def self.import_from_ldap(username = nil)
    @ldap = User.ldap_connection
    if username == nil
      filter1 = Net::LDAP::Filter.eq('sAMAccountType', '805306368') #Should be faster than multiple attribute query
      @filter = Net::LDAP::Filter.join(filter1)
    else
      filter1 = Net::LDAP::Filter.eq('sAMAccountType', '805306368') #Should be faster than multiple attribute query
      filter2 = Net::LDAP::Filter.eq('sAMAccountName', username.downcase)
      @filter = Net::LDAP::Filter.join(filter1, filter2)
    end
    @attrs = LDAP_CONFIG["read-attributes"]

    @ldap.search( :base => @ldap.base, :filter => @filter, :attributes => @attrs, :return_result => false) do |entry|
      user = User.find_or_create_by(object_guid: entry["objectGUID"].first.unpack("H*").first.to_s)

      user.username = entry["sAMAccountName"].first.downcase
      user.distinguishedname = entry["dn"].first

      @attrs.each do |key|
        value = entry[key.to_s]
        unless key.to_s == "objectguid"
          user.send("#{key}=", "") if value.count == 0
          user.send("#{key}=", value.first.to_s) if value.count == 1
          if value.count > 1
            value_array = []
            value.each do |v|
              value_array << v
            end
            user.send("#{key}=", value_array)
          end
        end
      end

      if user.new_record?
        user.update_column(:ldap_imported_at, Time.now)
      else
        if user.changed?
          user.ldap_imported_at =  Time.now
          user.save
        end
      end
    end
    # Title.extract
  end #Import



	def self.from_omniauth(auth)

    User.import_from_ldap(auth.info.email.split("@").first)

		user = User.find_by(username: auth.info.email.split("@").first)

    return user
    # where(auth.slice(:provider, :uid)).first_or_initialize.tap do |user|
      # user.provider = auth.provider
      # user.uid = auth.uid
      # user.name = auth.info.name
      # user.oauth_token = auth.credentials.token
      # user.oauth_expires_at = Time.at(auth.credentials.expires_at)
      # user.save!
    # end
  end


end
