class UserPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def show?
    user.admin? || (user.has_role?(:customer) && user.id == record.id)
  end

  def edit?
    user.admin? || (user.has_role?(:customer) && user.id == record.id)
  end

  def create?
    user.admin?
  end

  def update?
    user.admin? || (user.has_role?(:customer) && user.id == record.id)
  end

  def destroy?
    return false if user.id == record.id

    user.admin?
  end

  def access?
    user&.admin?
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.none
      end
    end
  end
end
