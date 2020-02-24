# -*- mode: ruby -*-
# vi: set ft=ruby :

# Require YAML module
require 'yaml'

ENV["VAGRANT_OLD_ENV_OBJC_DISABLE_INITIALIZE_FORK_SAFETY"] = "YES"

# Read YAML file with box details
all_inventory = YAML.load_file('inventory.yml')

domain_controller_inventory = all_inventory['all']['children']['windows']['children']['controller']['hosts']
domain_children_inventory = all_inventory['all']['children']['windows']['children']['domain_children']['hosts']
vault_inventory = all_inventory['all']['children']['ubuntu']['children']['vault_hosts']['hosts']
inventory = domain_controller_inventory.merge(domain_children_inventory).merge(vault_inventory)
network_ports = all_inventory['all']['vars']['vagrant_ports']

current_host = 1
vault_host = 0
Vagrant.configure("2") do |config|

  N = inventory.keys.count-1
  (0..N).each do |machine_id|
    host = inventory.keys[machine_id]
    config.vm.define host do |machine|
      machine.vm.hostname = host
      machine.vm.box = inventory[host]['vagrant_box']
      machine.vm.network "private_network", ip: inventory[host]['ansible_host']
        network_ports.each do |protocol,details|
          machine.vm.network :forwarded_port, guest: details['guest'], host: details['host']+machine_id, id: protocol
        end

      # Provision after all machines are up
      # this doesn't work for partial 'up' builds =/
      if machine_id == N
        machine.vm.provision :ansible do |ansible|
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
