class AppSetting < ActiveRecord::Base
  attr_accessible :set_key, :set_val
  self.primary_key = :set_key
  
  def self.get_setting(key, dflt=nil)
    begin
      setting = self.find(key)
      if setting.set_val == "true"
        return true
      elsif setting.set_val == "false"
        return false
      else
        return setting.set_val
      end
    rescue
      return dflt
    end
  end
end