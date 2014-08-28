module MCollective
 module Agent
  class Shell < RPC::Agent

    action "execute" do
      validate :cmd, String
      validate :full, :boolean

      out = []
      err = ""

      begin
        status = run("#{request[:cmd]}", :stdout => out, :stderr => :stderr, :chomp => false)

        reply[:exitcode] = status
        # If status set to true, then return all output
        if request[:full]
          reply[:stdout] = out
        else
          reply[:stdout] = out[0..76] + " ..."
        end
        reply.fail err if status != 0
      rescue Exception => e
        reply.fail e.to_s
      end

    end

  end
 end
end
