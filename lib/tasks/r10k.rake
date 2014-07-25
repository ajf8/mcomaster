namespace :r10k do
  desc "Install puppet modules using r10k"
  task :install do
    sh "env PUPPETFILE_DIR=./tools/puppet/external-modules r10k -v INFO puppetfile install"
  end
end
