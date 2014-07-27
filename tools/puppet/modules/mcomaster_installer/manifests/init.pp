# This class is called from the mcomaster install script (or Vagrantfile)
# and expects a yaml file to exist at either:
#   optional $answers class parameter
#   $modulepath/mcomaster_installer/answers.yaml
#   /etc/mcomaster_installer/answers.yaml
#
class mcomaster_installer(
  $answers = undef
) {

  $params=loadanyyaml($answers,
                      "/etc/mcomaster-installer/answers.yaml",
                      "${settings::modulepath}/${module_name}/answers.yaml")

  mcomaster_installer::yaml_to_class { ['puppetlabs', 'mcomaster', 'mcollective_server', 'mcollective_client', 'mcomaster_builder', 'mcomaster_ci']: }

  # Keep a more user-friendly name in the answers file
#  mcomaster_installer::yaml_to_class { 'puppetmaster': classname => 'puppet::server' }

}
