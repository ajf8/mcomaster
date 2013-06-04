metadata :name        => "Shell Command",
         :description => "Remote execution of bash commands",
         :author      => "Jeremy Carroll",
         :license     => "Apache v.2",
         :version     => "1.0",
         :url         => "http://github.com/phobos182/mcollective-plugins",
         :timeout     => 300

["execute"].each do |act|
  action act, :description => "#{act.capitalize} a command" do
    display :always

    input :cmd,
          :prompt      => "Command",
          :description => "The name of the command to #{act}",
          :type        => :string,
          :validation  => '^.+$',
          :optional    => false,
          :maxlength   => 300

    output :output,
           :description => "Command Output",
           :display_as  => "Output"

    output :error,
           :description => "Command Error",
           :display_as  => "Error"

    output :exitcode,
           :description => "Exit code of the shell process",
           :display_as  => "Exit Code"

  end
end
