module Mcomaster
  class ActionPolicy
    attr_accessor :config, :allow_unconfigured, :configdir, :caller, :action
    def self.authorize(request)
      ActionPolicy.new(request).authorize_request
    end

    def self.is_enabled?
      return AppSetting.get_setting("policies_enabled", false)
    end

    def initialize(request)
      @agent = request.agent
      @caller = request.caller
      @action = request.action
      @allow_unconfigured = AppSetting.get_setting("allow_unconfigured", false)
      @configdir = Rails.root
    end

    def authorize_request
      Policy.where(:agent => @agent).each do |policy|
        if check_policy(policy.callerid, policy.action)
          if policy.policy == "allow"
            return true
          else
            deny("explicit deny from policies in DB")
          end
        end
      end

      enable_default = AppSetting.get_setting('enable_default', false)
      if enable_default
        default_policy = PolicyDefault.find('default')
        if default_policy.length == 1 and default_policy[0].policy == "allow"
          return true
        else
          deny("denied by default policy")
        end
      end

      if @allow_unconfigured
        return true
      else
        deny('Could not load any valid policy files. Denying based on allow_unconfigured: %s' % @allow_unconfigured)
      end
    end

    # Check if a request made by a caller matches the state defined in the policy
    def check_policy(rpccaller, actions)
      # If we have a wildcard caller or the caller matches our policy line
      # then continue else skip this policy line\
      if (rpccaller != '*') && (rpccaller != @caller)
      return false
      end

      # If we have a wildcard actions list or the request action is in the list
      # of actions in the policy line continue, else skip this policy line
      if (actions != '*') && !(actions.split.include?(@action))
      return false
      end

      true
    end

    def deny(logline)
      #puts(logline)

      raise('You are not authorized to call this agent or action.')
    end
  end
end
