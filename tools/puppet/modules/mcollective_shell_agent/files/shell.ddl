metadata :name        => "Shell Command",
         :description => "Remote execution of bash commands",
         :author      => "Jeremy Carrol",
         :license     => "Apache v.2",
         :version     => "1.0-mcomaster",
         :url         => "http://github.com/phobos182/mcollective-plugins",
         :timeout     => 300

["execute"].each do |act|
  action act, :description => "#{act.capitalize} a command" do
    display :always

    input :command,
          :prompt      => "Command",
          :description => "The name of the command to #{act}",
          :type        => :string,
          :validation  => '^.+$',
          :optional    => false,
          :maxlength   => 300

    input :full,
          :prompt      => "Full-Status Output?",
          :description => "true / false, get full +80 character output back",
          :type        => :boolean,
          :optional    => true,
          :default     => true

    output :output,
           :description => "Command Output",
           :display_as  => "Output"

    output :exitcode,
           :description => "Exit code of the shell process",
           :display_as  => "Exit Code"

  end
end
