class TitlePolicy < ApplicationPolicy
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
    user.admin? if user
  end

  def show?
    user.admin? if user
  end

  def destroy?
    user.admin? if user
  end

  def extract?
    user.admin? if user
  end

  def update?
    user.admin? if user
  end

  def create?
    user.admin? if user
  end
end
