module Mcomaster
  class ActionPolicy
    attr_accessor :config, :configdir, :caller, :action
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
      @configdir = Rails.root
    end

    def authorize_request
      Policy.where(:agent => @agent).order("id").each do |policy|
        if check_policy(policy.callerid, policy.action)
          if policy.policy == "allow"
            return true
          else
            deny("explicit deny from policies in DB")
          end
        end
      end
      
      agent_default = PolicyDefault.find_by_name(@agent)
      unless agent_default.nil?
        if agent_default.policy == "allow"
          return true
        else
          deny("deny from agents default policy")
        end
      end

      enable_default = AppSetting.get_setting('defaults_enabled', false)
      if enable_default
        default_policy = PolicyDefault.find_by_name('default')
        if default_policy and default_policy.policy == "allow"
          return true
        else
          deny("denied by default policy")
        end
      end

      if AppSetting.get_setting("allow_unconfigured", false)
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
