$redis = Redis.new(:host => APP_CONFIG['redis_host'], :port => APP_CONFIG['redis_port'])
pass = APP_CONFIG['redis_pass']
if !pass.nil?
  $redis.pass(pass)
end
