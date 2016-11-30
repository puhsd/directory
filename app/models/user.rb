class User < ActiveRecord::Base
  require 'google/apis/plus_domains_v1'
  require 'googleauth'
  require 'googleauth/stores/file_token_store'

  # require 'fileutils'

  has_and_belongs_to_many :groups

  extend FriendlyId
  friendly_id :username, use: :slugged
# class User < ApplicationRecord
  enum access_level: { user: 0, manager: 1, admin: 2 }

  # Google Plus API constants
  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
  APPLICATION_NAME = 'Directory API Ruby Quickstart'
  CLIENT_SECRETS_PATH = File.join(Rails.root,'config','client_secret.json')
  # CREDENTIALS_PATH = File.join(Dir.home, '.credentials',"plus-domain-api.yaml")
  CREDENTIALS_PATH = File.join(Rails.root,'config',"plus-domain-api.yaml")
  SCOPE = Google::Apis::PlusDomainsV1::AUTH_PLUS_PROFILES_READ
  # end of Google Plus API constants

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

  def default_url
    # self.getGooglePlusURL(self.mail)
    self.googleService() unless @service
    url = nil
    begin

      response = @service.get_person(mail)
      url = response.url
    rescue => e
      puts e
    end
    return url
  end

  def set_default_url
    self.link = default_url
    self.save
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


  def googleService
    ##
    # Ensure valid credentials, either by restoring from the saved credentials
    # files or intitiating an OAuth2 authorization. If authorization is required,
    # the user's default browser will be launched to approve the request.
    #
    # @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
    def authorize
      FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

      client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
      token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
      authorizer = Google::Auth::UserAuthorizer.new(
        client_id, SCOPE, token_store)
      user_id = 'default'
      credentials = authorizer.get_credentials(user_id)
      if credentials.nil?
        url = authorizer.get_authorization_url(
          base_url: OOB_URI)
        puts "Open the following URL in the browser and enter the " +
             "resulting code after authorization"
        puts url
        code = gets
        credentials = authorizer.get_and_store_credentials_from_code(
          user_id: user_id, code: code, base_url: OOB_URI)
      end
      credentials
    end

    @service = Google::Apis::PlusDomainsV1::PlusDomainsService.new
    @service.client_options.application_name = APPLICATION_NAME
    @service.authorization = authorize
    @service
  end



  def getGooglePlusURL(email)
    self.googleService() unless @service
    response = @service.get_person(email)
    response.url
  end


end
