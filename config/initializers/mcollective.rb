require 'mcollective'

mco_conf = APP_CONFIG["mcollective_config"]
unless mco_conf.nil?
  MCollective::Config.instance.loadconfig(mco_conf)
end
