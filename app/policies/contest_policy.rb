class ContestPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user
        if user.admin?
          scope.all
        else
          scope.includes(:groups).where(groups: { id: [nil, user.group_ids].flatten })
        end
      else
        # when the groups are set, visitors can't see them
        # here we load the contest without a group
        # means it's visible to all
        scope.includes(:groups).where(groups: { id: nil })
      end
    end
  end

  def create?
    user && user.staff?
  end

  def show?
    if public_contest?
      true
    else
      user && (user.admin? || in_group?)
    end
  end

  def show_details?
    show? && (record.started? || supervise?)
  end

  def update?
    supervise?
  end

  def create_solution?
    user && show_details? && (record.ongoing? || user.admin? || in_judger_group?)
  end

  def rejudge_solution?
    user && (user.admin? || in_judger_group?)
  end

  def rejudge_all_solution?
    user && (user.admin? || (in_judger_group? && user.moderator?))
  end

  alias_method :send_notification?, :rejudge_all_solution?

  def destroy?
    user && user.admin?
  end

  def public_contest?
    @public_contest ||= record.public_contest?
  end

  def in_judger_group?
    @in_judger_group ||= record.in_judger_group?(user)
  end

  def in_visible_to_group?
    @in_visible_to_group ||= record.in_visible_to_group?(user)
  end

  def in_group?
    @in_group ||= in_judger_group? || in_visible_to_group?
  end

  def supervise?
    @supervise ||= user && (user.admin? || (in_judger_group? && user.moderator?))
  end

end
