class UserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      # scope
      if user.admin?
        scope.all
      else
        # scope.all
        # scope.where(:index => true)
      end

    end
  end

  def index?
    true
  end

  def import?
    user.admin? || (user.id == record.id if record) if user
  end

  def default_url?
    user.admin? || user.manager? || (user.id == record.id if record) if user
  end

  def ldap_sync?
    user.admin? if user
  end


  def update?
    user.admin? if user
  end

  def create?
    user.admin? if user
  end
end
