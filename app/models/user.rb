class User < ApplicationRecord

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
    ldap = Net::LDAP.new
    ldap.host = LDAP_CONFIG["host"]
    ldap.port = LDAP_CONFIG["port"]
    ldap.base = LDAP_CONFIG["base"]
    ldap.encryption LDAP_CONFIG["encryption"]
    if username && password
      ldap.auth "#{username}@puhsd.org", password
    else
      ldap.auth LDAP_CONFIG["admin_username"], LDAP_CONFIG["admin_password"]
    end
    return ldap
  end

  def self.import_from_ldap(username = nil)
    @ldap = User.ldap_connection
    if username == nil
      @filter = Net::LDAP::Filter.eq('sAMAccountType', '805306368') #Should be faster than multiple attribute query
    else
      filter1 = Net::LDAP::Filter.eq('sAMAccountType', '805306368') #Should be faster than multiple attribute query
      filter2 = Net::LDAP::Filter.eq('sAMAccountName', username.downcase)
      # guid_bin = [object_guid].pack("H*")
      @filter = Net::LDAP::Filter.join(filter1, filter2)
    end
    @attrs = LDAP_CONFIG["read-attributes"]

    @ldap.search( :base => @ldap.base, :filter => @filter, :attributes => @attrs, :return_result => false) do |entry|
      user = User.find_or_create_by(username: entry["sAMAccountName"].first.downcase)
        if user.new_record? || user.object_guid.blank?
          user.update_attribute(:object_guid, entry["objectGUID"].first.unpack("H*").first.to_s)
        end

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
  end #Import

end
