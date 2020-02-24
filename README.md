# Vagrant Vault Kerberos Example

The goal is this is to build an example setup using Vagrant that:

- Installs multiple Windows servers
- Configures Active Directory
- Installs IIS and .NET Core
- Hosts an app in an IIS application pool
- Assigns an identity to the application pool
- Installs a Vault cluster
- Installs the Vault Kerberos plugin
- Configures the app to authenticate to Vault with Kerberos

Active Directory setup based on [jborean93/ansible-windows](https://github.com/jborean93/ansible-windows).

## Setup

To perform the setup:

1) Bring up the hosts
```
$ vagrant up
Bringing machine 'dc' up with 'virtualbox' provider...
Bringing machine 'web' up with 'virtualbox' provider...
Bringing machine 'vault' up with 'virtualbox' provider...
...
PLAY RECAP *********************************************************************
dc                         : ok=15   changed=9    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
vault                      : ok=38   changed=23   unreachable=0    failed=0    skipped=37   rescued=0    ignored=1   
web                        : ok=25   changed=20   unreachable=0    failed=0    skipped=3    rescued=0    ignored=0   

```

If the provision step fails, try running again with `vagrant provision vault`.

2) Ensure Vault is alive
```
$ export VAULT_ADDR=http://localhost:30102
$ vault status
Key                Value
---                -----
Seal Type          shamir
Initialized        false
Sealed             true
Total Shares       0
Threshold          0
Unseal Progress    0/0
Unseal Nonce       n/a
Version            n/a
HA Enabled         false
```

3) Initialize and unseal vault. Login with the root token.

For simplicity, this is set with just one unseal key. Use this to unseal Vault and the root token to login. Don't do this in production.

```
$ vault operator init -key-shares=1 -key-threshold=1
Unseal Key 1: ZypmDR/1ACPxF7dJOA+wf17/+/2m51Gq+TWZVXgLas0=

Initial Root Token: s.kQUDJ2mqksuHCZXC3AcSdiL9

Vault initialized with 1 key shares and a key threshold of 1. Please securely
distribute the key shares printed above. When the Vault is re-sealed,
restarted, or stopped, you must supply at least 1 of these keys to unseal it
before it can start servicing requests.

Vault does not store the generated master key. Without at least 1 key to
reconstruct the master key, Vault will remain permanently sealed!

It is possible to generate new unseal keys, provided you have a quorum of
existing unseal keys shares. See "vault operator rekey" for more information.
```
```
$ vault operator unseal
Unseal Key (will be hidden):
Key             Value
---             -----
Seal Type       shamir
Initialized     true
Sealed          false
Total Shares    1
Threshold       1
Version         1.3.2
Cluster Name    dc1
Cluster ID      98eabf14-049b-0e08-3d3c-253bc868305d
HA Enabled      false
```
```
$ vault login
Token (will be hidden):
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                  Value
---                  -----
token                s.kQUDJ2mqksuHCZXC3AcSdiL9
token_accessor       2hJQXtO716S5qPrNQs3FjADZ
token_duration       ∞
token_renewable      false
token_policies       ["root"]
identity_policies    []
policies             ["root"]
```

4) Configure Vault using Terraform
```
$ terraform apply -var-file=vault.tfvars -auto-approve
vault_generic_endpoint.plugin_auth_kerberos: Creating...
vault_ldap_auth_backend.ldap: Creating...
vault_generic_endpoint.plugin_auth_kerberos: Creation complete after 0s [id=sys/plugins/catalog/auth/kerberos]
vault_ldap_auth_backend.ldap: Creation complete after 0s [id=ldap]
vault_generic_endpoint.auth_kerberos: Creating...
vault_generic_endpoint.auth_kerberos: Creation complete after 0s [id=sys/auth/kerberos/domain.local]
vault_generic_endpoint.auth_kerberos_config: Creating...
vault_generic_endpoint.auth_kerberos_config: Creation complete after 1s [id=auth/kerberos/domain.local/config]
vault_generic_endpoint.auth_kerberos_config_ldap: Creating...
vault_generic_endpoint.auth_kerberos_config_ldap: Creation complete after 0s [id=auth/kerberos/domain.local/config/ldap]
vault_ldap_auth_backend_group.group: Creating...
vault_ldap_auth_backend_group.group: Creation complete after 0s [id=auth/kerberos/domain.local/groups/Domain Users]

Apply complete! Resources: 6 added, 0 changed, 0 destroyed.
```

## Requirements

- VirtualBox
- Vagrant
- Ansible
- Terraform

## References

https://github.com/hashicorp/vault-plugin-auth-kerberos
https://docs.microsoft.com/en-us/iis/configuration/system.applicationHost/applicationPools/add/processModel
