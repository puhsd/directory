class Group < ApplicationRecord
  has_and_belongs_to_many :users
  extend FriendlyId
  friendly_id :samaccountname, use: [:slugged, :finders]

  def self.import_from_ldap(group = nil)
    @ldap = User.ldap_connection


    if group == nil
      @filter = Net::LDAP::Filter.eq('sAMAccountType', '268435456') #Should be faster than multiple attribute query
    else
      filter1 = Net::LDAP::Filter.eq('sAMAccountType', '268435456') #Should be faster than multiple attribute query
      filter2 = Net::LDAP::Filter.eq('sAMAccountName', group.downcase)
      # guid_bin = [object_guid].pack("H*")
      @filter = Net::LDAP::Filter.join(filter1, filter2)
    end

    @ldap.search( :base => @ldap.base, :filter => @filter, :return_result => false) do |entry|

      group = Group.find_or_create_by(object_guid: entry["objectGUID"].first.unpack("H*").first.to_s)

      group.samaccountname = entry["sAMAccountName"].first
      group.dn = entry["dn"].first
      group.mail = entry["mail"].first.downcase if entry.respond_to?(:mail)
      group.displayname = entry["displayname"].first if entry.respond_to?(:displayname)

      if entry["dn"].first.ends_with? "OU=Distribution,OU=Groups,OU=Staff,OU=Accounts,DC=PUHSD,DC=ORG"
        group.grouptype = "Distribution"
      elsif entry["dn"].first.ends_with? "OU=Security,OU=Groups,OU=Staff,OU=Accounts,DC=PUHSD,DC=ORG"
        group.grouptype = "Security"
      else
        group.grouptype = "Other"
      end


      if group.grouptype != "Other"
        if group.new_record?
          group.update_column(:ldap_imported_at, Time.now)
        else
          if group.changed?
            group.ldap_imported_at =  Time.now
            group.save
          end
        end



        # members = entry.respond_to?(:member) ? entry.member.collect {|m| m.split(",").first.gsub!(/CN=/,"")} : Array.new
        members = entry.respond_to?(:member) ? entry.member.collect {|m| m } : Array.new
        if (entry['member;range=0-1499'])
           members +=  entry['member;range=0-1499'].collect {|m| m.split(",").first.gsub!(/CN=/,"")}
           members += Group.getAllMembers(@ldap, entry.samaccountname,  @ldap.base, @filter, 1500)
        end


        # group.users.delete_all

        users = group.users.collect { |user| user.distinguishedname }

        (users - members).each do |dn|
          group.users.delete(User.find_by_distinguishedname(dn))
        end


        (members - users).each do |member|
          user = User.find_by_distinguishedname(member)
          group.users << user if user
        end


      end
    end
  end #

private

  def self.getAllMembers(ldap, group_name,  base, filter, range = 0)
    members = Array.new

     result_attrs = ["member;range=#{range}-*", "sAMAccountName"]
     ldap.search(:base => base, :attributes => result_attrs, :filter => filter) do |group|
        if (group["member;range=#{range}-#{range+1499}"].size > 0)

          members +=  group["member;range=#{range}-#{range+1499}"].collect {|m| m.split(",").first.gsub!(/CN=/,"")}
          members += getAllMembers(ldap, group_name,  base, filter, (range + 1500 ))
        else
          members +=  group["member;range=#{range}-*"].collect {|m| m.split(",").first.gsub!(/CN=/,"")}
        end
     end

    return members
  end


end
