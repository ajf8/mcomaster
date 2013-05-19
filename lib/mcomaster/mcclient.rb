require 'mcollective'

include MCollective::RPC

module Mcomaster
  module McClient
    def mcm_rpcclient(agent)
      options = MCollective::Util.default_options
      if !APP_CONFIG['mcollective'].nil?
        options.merge!(APP_CONFIG['mcollective'])
      end
      mc = MCollective::RPC::rpcclient(agent, :exit_on_failure => false, :options => options)
      mc.progress = false
      mc
    end

    def get_real_ddl(name)
      mc = mcm_rpcclient(name)
      mc.ddl
    end
    
    def get_ddl(name)
      ddl = get_real_ddl(name)
      # backwards compatibility for older versions of mcollective
      # (or the other way around, I forget)
      transform = { :meta => ddl.meta }
      if ddl.actions
        actions = {}
        for action in ddl.actions
          actions[action] = ddl.action_interface(action)
        end
        transform[:actions] = actions
      else
        transform[:actions] = ddl.entities
      end
      transform
    end

    def get_inventory()
      cached = $redis.get("inventory");

      if !cached.nil?
        return JSON.parse(cached)
      else
        mc = mcm_rpcclient("rpcutil")
        inv = mc.inventory
        serialized = inv.jsonize
        res = JSON.parse(serialized)
        $redis.set("inventory", serialized)
        $redis.expire("inventory", 60)
        return res
      end
    end

    def convert_filter(original)
      filters = MCollective::Util::empty_filter()
      filters.merge!(original)
      filters.each{ |filter_type,filter_array|
        if filter_array.is_a?(Array)
          filter_array.each { |filter_item|
            if (filter_item.is_a?(Hash))
              filter_item.symbolize_keys!
            end
          }
        end
      }
      return filters
    end
  end
end