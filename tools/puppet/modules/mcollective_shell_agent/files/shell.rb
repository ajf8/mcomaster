module MCollective
 module Agent
  class Shell < RPC::Agent

    action "run" do
      validate :command, String

      out = []
      err = ""

      begin
        status = run("#{request[:command]}", :stdout => out, :stderr => :stderr, :chomp => false)

        reply[:exitcode] = status
        # If status set to true, then return all output
        reply[:stdout] = out
        reply.fail err if status != 0
      rescue Exception => e
        reply.fail e.to_s
      end

    end

  end
 end
end
