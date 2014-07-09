
module Mcomaster
    class ActionPolicy
      attr_accessor :config, :allow_unconfigured, :configdir, :caller, :action

      def self.authorize(request)
        ActionPolicy.new(request).authorize_request
      end
      
      def self.is_enabled?
        return false unless APP_CONFIG['actionpolicy']
        return APP_CONFIG['actionpolicy']['enabled'] if APP_CONFIG['actionpolicy']['enabled']
        return false
      end
      
      def use_files?
        return config_fetch('use_files', false)
      end

      def config_fetch(key, dflt=nil)
        return dflt unless APP_CONFIG.has_key?('actionpolicy')
        if APP_CONFIG['actionpolicy'].has_key?(key)
          return APP_CONFIG['actionpolicy'][key]
        end
        return dflt
      end

      def initialize(request)
        @agent = request.agent
        @caller = request.caller
        @action = request.action
        @allow_unconfigured = !!(config_fetch('allow_unconfigured', 'n') =~ /^1|y/i)
        @configdir = Rails.root
      end

      def authorize_from_file
        policy_file = lookup_policy_file
        # No policy file exists and allow_unconfigured is false
        if !policy_file && !@allow_unconfigured
          deny('Could not load any valid policy files. Denying based on allow_unconfigured: %s' % @allow_unconfigured)
        # No policy exists but allow_unconfigured is true
        elsif !(policy_file) && @allow_unconfigured
          #puts('Could not load any valid policy files. Allowing based on allow_unconfigured: %s' % @allow_unconfigured)
          return true
        end
  
        # A policy file exists
        parse_policy_file(policy_file)
      end
      
      def authorize_from_db
        Policy.where(:agent => @agent).each do |policy| 
          if check_policy(policy.callerid, policy.action)
            if policy.policy == "allow"
              return true
            else
              deny("explicit deny from policies in DB")
            end
          end
        end
        
        if config_fetch('enable_default', 'n') =~ /^1|y/i
          default_policy = PolicyDefault.where(:name => config_fetch('default_name', 'default'))
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
      
      def authorize_request
        # Lookup the policy file. If none exists and @allow_unconfigured
        # is false the request gets denied.
        
        if use_files?
          authorize_from_file
        else
          authorize_from_db
        end  
      end

      def parse_policy_file(policy_file)
        puts('Parsing policyfile for %s: %s' % [@agent, policy_file])
        allow = @allow_unconfigured

        File.read(policy_file).each_line do |line|
          next if line =~ /^(#.*|\s*)$/

          if line =~ /^policy\s+default\s+(\w+)/
            if $1 == 'allow'
              allow = true
            else
              allow = false
            end
          elsif line =~ /^(allow|deny)\t+(.+?)\t+(.+?)$/
            if check_policy($2, $3)
              if $1 == 'allow'
                return true
              else
                deny("Denying based on explicit 'deny' policy rule in policyfile: %s" % File.basename(policy_file))
              end
            end
          else
            puts("Cannot parse policy line: %s" % line)
          end
        end

        allow || deny("Denying based on default policy in %s" % File.basename(policy_file))
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

      # Here we lookup the full path of the policy file. If the policyfile
      # does not exist, we check to see if a default file was set and
      # determine its full path. If no default file exists, or default was
      # not specified, we return false.
      def lookup_policy_file
        policy_file = File.join(@configdir, "policies", "#{@agent}.policy")

        puts("Looking for policy in #{policy_file}")

        return policy_file if File.exist?(policy_file)

        if config_fetch('enable_default', 'n') =~ /^1|y/i
          defaultname = config_fetch('default_name', 'default')
          default_file = File.join(@configdir, "policies", "#{defaultname}.policy")

          puts("Initial lookup failed: looking for policy in #{default_file}")

          return default_file if File.exist?(default_file)
        end

        puts('Could not find any policy files.')
        nil
      end

      def deny(logline)
        #puts(logline)

        raise('You are not authorized to call this agent or action.')
      end
    end
end
