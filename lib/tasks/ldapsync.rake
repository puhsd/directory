desc "Syncking With LDAP"
task :ldap_sync => :environment do
  User.import_from_ldap
  Title.extract
  Group.import_from_ldap
end
