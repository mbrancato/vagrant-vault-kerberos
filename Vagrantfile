# -*- mode: ruby -*-
# vi: set ft=ruby :

# Require YAML module
require 'yaml'

ENV["VAGRANT_OLD_ENV_OBJC_DISABLE_INITIALIZE_FORK_SAFETY"] = "YES"

# Read YAML file with box details
inventory = YAML.load_file('inventory.yml')

domain_controller_count = inventory['all']['children']['windows']['children']['controller']['hosts'].keys.count
domain_children_count = inventory['all']['children']['windows']['children']['domain_children']['hosts'].keys.count
vault_count = inventory['all']['children']['ubuntu']['children']['vault_hosts']['hosts'].keys.count

current_host = 0
Vagrant.configure("2") do |config|
  inventory['all']['children']['windows']['children']['controller']['hosts'].each do |server,details|
    config.vm.define server do |dc|
      dc.vm.box = details['vagrant_box']
      dc.vm.hostname = server
      dc.vm.network :private_network, ip: details['ansible_host']
      inventory['all']['children']['windows']['vars']['vagrant_ports'].each do |protocol,details|
        dc.vm.network :forwarded_port, guest: details['guest'], host: details['host'], id: protocol
      end

      dc.vm.provider :virtualbox do |v|
        v.name = File.basename(File.dirname(__FILE__)) + "_" + server + "_" + Time.now.to_i.to_s
        v.gui = false
        v.memory = 2048
        v.cpus = 2
      end
      current_host = current_host + 1
    end
  end

  inventory['all']['children']['windows']['children']['domain_children']['hosts'].each do |server,details|
    config.vm.define server do |srv|
      srv.vm.box = details['vagrant_box']
      srv.vm.hostname = server
      srv.vm.network :private_network, ip: details['ansible_host']
      inventory['all']['children']['windows']['vars']['vagrant_ports'].each do |protocol, details|
        srv.vm.network :forwarded_port, guest: details['guest'], host: details['host'] + current_host, id: protocol
      end

      srv.vm.provider :virtualbox do |v|
        v.name = File.basename(File.dirname(__FILE__)) + "_" + server + "_" + Time.now.to_i.to_s
        v.gui = false
        v.memory = 2048
        v.cpus = 2
      end
      current_host = current_host + 1
    end
  end

  inventory['all']['children']['ubuntu']['children']['vault_hosts']['hosts'].each do |server,details|
    config.vm.define server do |srv|
      srv.vm.box = details['vagrant_box']
      srv.vm.hostname = server
      srv.vm.network :private_network, ip: details['ansible_host']
      inventory['all']['children']['ubuntu']['vars']['vagrant_ports'].each do |protocol, details|
        srv.vm.network :forwarded_port, guest: details['guest'], host: details['host'] + current_host, id: protocol
      end

      srv.vm.provider :virtualbox do |v|
        v.name = File.basename(File.dirname(__FILE__)) + "_" + server + "_" + Time.now.to_i.to_s
        v.gui = false
        v.memory = 512
        v.cpus = 2
      end
      current_host = current_host + 1

      if current_host >= domain_controller_count + domain_children_count + vault_count then
        config.vm.provision "ansible" do |ansible|
          ansible.playbook = "main.yml"
          ansible.limit = "all"
          ansible.inventory_path = "inventory.yml"
          ansible.galaxy_role_file = "requirements.yml"
          ansible.verbose = "-vv"
        end
      end
    end
  end

end
