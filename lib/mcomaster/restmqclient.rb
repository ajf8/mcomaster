module Mcomaster
  module RestMQ 
    require 'uuidtools'
    
    QUEUESET = 'QUEUESET' # queue index
    UUID_SUFFIX = ':UUID' # queue unique id
    QUEUE_SUFFIX = ':queue' # suffix to identify each queue's LIST

    def rmq_uuid
      UUIDTools::UUID.random_create.to_s
    end
        
    def rmq_send(txid, msg, expiry=300)
      q1 = txid + QUEUE_SUFFIX
      uuid = $redis.incr txid + UUID_SUFFIX
      #$redis.sadd QUEUESET, q1
      lkey = txid + ':' + uuid.to_s
      $redis.set lkey, msg.jsonize
      $redis.lpush q1, lkey
      
      $redis.expire q1, expiry
      $redis.expire lkey, expiry 
      lkey
    end
  end
end
