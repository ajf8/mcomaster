require 'securerandom'
require 'pathname'

# The Job class manages the spawning and state tracking for a process as it's
# running.
#
# The general approach we take is to create a directory per Job
# (Job#state_directory), and populate it as follows:

#   command    - the command we've been asked to run
#   wrapper    - a short program that spawns the command and collects its exit
#                status
#   error      - any problem in spawning the process
#   pid        - the pid of the spawned process
#   stdout     - stdout from the process
#   stderr     - stderr from the process
#   exitstatus - the exitstatus of the spawned process

# The wrapper process is detached from the mcollectived process, so restarting
# the mcollectived will not terminate the process.

module MCollective
  module Agent
    class Shell<RPC::Agent
      class Job
        @@ruby = nil

        # get all the jobs with state
        def self.list
          jobs = []
          Dir.entries(state_path).each do |handle|
            next if handle[0] == '.'
            jobs << Job.new(handle)
          end
          return jobs
        end

        attr_reader :command, :handle, :exitcode, :signal, :pid
        def initialize(handle = nil)
          if !handle
            @handle = SecureRandom.uuid
            Pathname.new(state_directory).mkpath
          else
            @handle = handle

            commandfile = "#{state_directory}/command"
            if File.exists?(commandfile)
              @command = IO.read(commandfile).chomp
            end

            pidfile = "#{state_directory}/pid"
            if File.exists?(pidfile)
              @pid = Integer(IO.read(pidfile))
            end

            get_exitcode
          end
        end

        def start_command(command)
          @command = command
          # We create a manager process which then spawns the command we want
          # to run, the manager then writes a 'pid' file on succesful spawn, or
          # an 'error' file.  Assuming success it waits for completion of the
          # process and records the exit status to the 'exitstatus' file.
          File.open("#{state_directory}/command", 'w') do |fh|
            fh.puts command
          end

          File.open("#{state_directory}/wrapper", 'w') do |fh|
            fh.puts wrapper
          end

          manager = ::Process.spawn(find_ruby, "#{state_directory}/wrapper", {
            :chdir => '/',
            :in => :close,
            :out => :close,
            :err => :close,
          })

          if manager == nil
            raise "Couldn't spawn manager process"
          end

          # busy wait for a pid or error file
          while !File.exists?("#{state_directory}/pid") && !File.exists?("#{state_directory}/error")
            sleep 0.1
          end

          ::Process.detach(manager)

          if File.exists?("#{state_directory}/pid")
            @pid = Integer(IO.read("#{state_directory}/pid"))
          else
            # we must have an error file
            raise IO.read("#{state_directory}/error")
          end
        end

        def stdout(offset = 0)
          fh = File.new("#{state_directory}/stdout", 'rb')
          fh.seek(offset, IO::SEEK_SET)
          out = fh.read
          fh.close
          return out
        end

        def stderr(offset = 0)
          fh = File.new("#{state_directory}/stderr", 'rb')
          fh.seek(offset, IO::SEEK_SET)
          err = fh.read
          fh.close
          return err
        end

        def status
          if File.exists?("#{state_directory}/error")
            # Process failed to start
            return :failed
          end

          if !File.exists?("#{state_directory}/pid")
            # We haven't started yet
            return :starting
          end

          if File.exists?("#{state_directory}/exitstatus")
            # The manager has written out the exitstatus, so the process is done
            return :stopped
          end

          return :running
        end

        def kill
          ::Process.kill('TERM', pid)
        end

        def wait_for_process
          while status == :running
            sleep 0.1
          end
          get_exitcode
        end

        def cleanup_state
          FileUtils.remove_entry_secure state_directory
        end

        private

        def self.state_path
          if Util.windows?
            default = "C:/ProgramData/mcollective-shell"
          else
            default = "/var/run/mcollective-shell"
          end

          Config.instance.pluginconf['shell.state_path'] || default
        end

        def get_exitcode
          statusfile = "#{state_directory}/exitstatus"
          if File.exists?(statusfile)
            status = Integer(IO.read(statusfile))
            @signal = status & 0xff
            @exitcode = status >> 8
          end
        end

        def find_ruby
          if @@ruby
            return @@ruby
          end

          ruby_config = begin
            ::RbConfig::CONFIG
          rescue NameError
            ::Config::CONFIG
          end

          candidates = [
            File.join(ruby_config['bindir'], ruby_config['ruby_install_name']) + ruby_config['EXEEXT'],
            'ruby',
          ]

          found = candidates.find { |path| system('%s -e 42' % path) }

          if found
            @@ruby = found
            return @@ruby
          else
            raise "No ruby found via Config or PATH"
          end
        end

        def wrapper
          return <<-WRAPPER
            command = IO.read("#{state_directory}/command").chomp

            options = {
              :chdir => '/',
              :out => "#{state_directory}/stdout",
              :err => "#{state_directory}/stderr",
            }

            begin
              pid = ::Process.spawn(command, options)

              File.open("#{state_directory}/pid", 'w') do |fh|
                fh.puts pid
              end

              ::Process.waitpid(pid)

              if $?.nil?
                # On win32 $? doesn't seem to get set - probably need to grab a
                # handle then call GetExitCode
                exitstatus = 0
              else
                exitstatus = $?.to_i
              end

              File.open("#{state_directory}/exitstatus", 'w') do |fh|
                fh.puts exitstatus
              end

            rescue Exception => e
              File.open("#{state_directory}/error", 'w') do |fh|
                fh.puts e
              end
            end
          WRAPPER
        end

        def state_directory
          "#{self.class.state_path}/#{@handle}"
        end
      end
    end
  end
end
