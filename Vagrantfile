# -*- mode: ruby -*-
# vi: set ft=ruby :

##### https://dev.to/mattdark/using-docker-as-provider-for-vagrant-10me

Vagrant.require_version ">= 1.8"
VAGRANTFILE_API_VERSION = "2"

VAGRANT_BOX = "generic/ubuntu2004"

#DOCKER_GID = 121
DOCKER_GID = `stat -c '%g' /var/run/docker.sock | tr -d '\n'`

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.define "proxy.squid.host", autostart: true do |proxy|
    proxy.vm.box = VAGRANT_BOX
    proxy.vm.hostname = "proxy.squid.host"

    proxy.vm.provider  :docker do |d, override|
      override.vm.box = nil
      d.name = "proxy.squid.host"
      d.build_dir = "."
      d.dockerfile = "Dockerfile.ubuntu.systemd.dind"
      d.build_args = ["--build-arg", "DOCKER_GID=#{DOCKER_GID}"]
      d.remains_running = true
      d.has_ssh = true
      d.create_args = ["--runtime=sysbox-runc"]
#      d.ports = ["3128:3128"]

      ### NOTE working
      ### !!! NOTE docker provider ignores ownership and permissions defined in vagrant 
      ###          but uses host owner instead and respects file permissions has been setted on host 
      override.vm.synced_folder "./vagrant_var/var", "/vagrant_var/var",
        owner: "proxy", group: "proxy",
        mount_options: ["uid=13", "gid=13", "dmode=777", "fmode=777"]
    end

    proxy.vm.provider :virtualbox do |v, override|
      override.vm.box = VAGRANT_BOX
      v.name = "proxy.squid.host"
      v.linked_clone = true if Gem::Version.new(Vagrant::VERSION) >= Gem::Version.new('1.8.0')
      # shortcuts for memory and CPU settings
      v.memory = "4096"
      v.cpus = "4"
      v.customize ["modifyvm", :id, "--cpuexecutioncap", "50"]
      
      ### NOTE working
      ### TODO rsync accepts vagrant permissions but is a one-way sync so it needs a helper-mount 
      ###      to one more dir with virtualbox default method to push back modified files to host
      ### https://developer.hashicorp.com/vagrant/docs/synced-folders/rsync
      ##proxy.vm.synced_folder "./vagrant_var/var", "/vagrant_var/var", type: "rsync"
      #override.vm.synced_folder "./vagrant_var/var", "/vagrant_var/var", type: "rsync",
      #  owner: "proxy", group: "proxy",
      #  mount_options: ["uid=13", "gid=13"],
      #  rsync__exclude: ".git/", 
      #  rsync__args: ["--verbose", "--archive", "--delete", "-z"], 
      #  rsync__rsync_ownership: true

      ### TODO test
      ### Linux host => linux VM (using virtualbox provider):
      ### somehow synced files can not be opened for writing... ???
      ### !!! NOTE on host, permissions on synced folder for vagrant using virtualbox provider must be 777 for ALL users !!!
      #proxy.vm.synced_folder "./vagrant_var/var", "/vagrant_var/var",
      #  owner: "proxy", group: "proxy",
      #  mount_options: ["uid=13", "gid=13", "dmode=777", "fmode=777"]


      # override.vm.synced_folder "./vagrant_var/var", "/vagrant_var/var", type: "nfs",
      #   nfs_export: "true",
      #   nfs_version: 3,
      #   nfs_udp: true
      #   #linux__nfs_options: ['rw','no_subtree_check','all_squash','async']
      #   #map_uid: "proxy",
      #   #map_gid: "proxy"
      # ### NFS needs private network
      # override.vm.network "private_network", type: "dhcp", auto_config: "true"
      # ### ls: reading directory '/vagrant_var/var/log/': Stale file handle


      override.vm.synced_folder "./vagrant_var/var", "/vagrant_var/var", type: "sshfs"
    end


    ### NOTE systemd requires some extra time to start
    proxy.vm.boot_timeout = 600

    proxy.vm.provision "docker" do |d|
      #d.build_image "/vagrant_data/container",
      #  args: "--tag docker.io/ubuntu/squid:4.10-20.04_beta_custom"
      d.images = ["docker.io/ubuntu/squid:4.10-20.04_beta"]
      #d.pull_images "docker.io/ubuntu/squid:4.10-20.04_beta"
      d.run "proxy.squid.container",
        image: "docker.io/ubuntu/squid:4.10-20.04_beta",
        #cmd: "bash -l",
        #args: " \
        #       -v '/vagrant_data:/vagrant' \
        #       -v '/vagrant_data/tmp/proxy/var/log/squid:/var/log/squid' \
        #       -v '/vagrant_data/tmp/proxy/var/spool/squid:/var/spool/squid' \
        #       -v '/vagrant_data/tmp/proxy/squid.conf:/etc/squid/squid.conf' \
        #       -v '/app/var/log/squid:/var/log/squid' \
        #
        #       -v '/vagrant_var/var/log/squid:/var/log/squid' \
        #       -v '/vagrant_var/var/spool/squid:/var/spool/squid' \
        #       ",
        args: " \
               -e TZ=UTC \
               -p 3128:3128 \
               -v '/vagrant_etc/squid.conf:/etc/squid/squid.conf' \
               -v '/vagrant_var/var/log/squid:/var/log/squid' \
               -v '/vagrant_var/var/spool/squid:/var/spool/squid' \
               ",
        daemonize: true
    end

    ###proxy.vm.synced_folder ".", "/vagrant_data", disabled: true
    
    ##proxy.vm.network "forwarded_port", guest: 3128, host: 3128, guest_ip: "172.21.0.10"
    proxy.vm.network "forwarded_port", guest: 3128, host: 3128
    #proxy.vm.network "private_network", ip: "10.0.0.10"

    ### OK because it is 'readonly' files
    proxy.vm.synced_folder "./vagrant_etc/", "/vagrant_etc", owner: "root", group: "root", mount_options: ["uid=0", "gid=0"]
    
    #if Vagrant::proxy.vm.provider == "virtualbox" then
    #end
  end


  config.vm.synced_folder ".", "/vagrant_data"
  ###config.vm.synced_folder "./vagrant_etc/", "/vagrant_etc", owner: "proxy", group: "proxy", mount_options: ["uid=13", "gid=13"]
  #config.vm.synced_folder "./vagrant_etc", "/vagrant_etc", mount_options: ["uid=13", "gid=13"]
  #config.vm.synced_folder "./vagrant_var/", "/vagrant_var", create: true, owner: "proxy", group: "proxy", mount_options: ["uid=13", "gid=13"]

  #config.vm.synced_folder "./vagrant_var/var/log", "/vagrant_var/var/log", owner: "proxy", group: "proxy"
  #config.vm.synced_folder "./vagrant_var/var/spool", "/vagrant_var/var/spool", owner: "proxy", group: "proxy"
  ###config.vm.synced_folder "./vagrant_var/var", "/vagrant_var/var", owner: "proxy", group: "proxy"

  #config.vm.synced_folder "./vagrant_var/", "/vagrant_var"


  ### NOTE Vagrant does not support alpine's ash shell...
  ###if "#{config.vm.provider.dockerfile}" == "Dockerfile.alpine" then
  ###  config.ssh.shell = "sh -l"
  ###end
  #config.ssh.shell = "ash -l"

  # Install Docker and pull an image
  #config.vm.provision :docker do |d|
  #  d.pull_images "alpine:3.18"
  #end
end
