class GroupPolicy < ApplicationPolicy
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
    user.admin? or user.manager? if user
  end

  def show?
    user.admin? or user.manager? if user
  end

  def destroy?
    user.admin? if user
  end

  def import?
    user.admin? if user
  end

  def update?
    user.admin? if user
  end

  def create?
    user.admin? if user
  end
end
