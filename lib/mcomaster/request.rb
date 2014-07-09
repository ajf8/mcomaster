module Mcomaster
  class Request
    attr_accessor :agent, :caller, :action
    
    def initialize(agent, caller, action)
      @agent = agent
      @caller = caller
      @action = action
    end
  end
end