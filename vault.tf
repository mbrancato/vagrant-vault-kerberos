variable "vault_keytab" {
  type = string
}

variable "plugin_sha256" {
  type = string
}

provider "vault" {}

resource "vault_generic_endpoint" "plugin_auth_kerberos" {
  path                 = "sys/plugins/catalog/auth/kerberos"
  disable_read         = false
  disable_delete       = false
  ignore_absent_fields = true

  data_json = jsonencode({
    sha_256 = var.plugin_sha256
    command = "vault-plugin-auth-kerberos"
  })
}

resource "vault_generic_endpoint" "auth_kerberos" {
  depends_on   = [vault_generic_endpoint.plugin_auth_kerberos]
  path         = "sys/auth/kerberos/domain.local"
  disable_read = true

  data_json = jsonencode({
    type = "kerberos"
    config = {
      passthrough_request_headers = ["Authorization"]
      allowed_response_headers    = ["www-authenticate"]
    }
  })
}

resource "vault_generic_endpoint" "auth_kerberos_config" {
  depends_on           = [vault_generic_endpoint.plugin_auth_kerberos, vault_generic_endpoint.auth_kerberos]
  path                 = "${substr(vault_generic_endpoint.auth_kerberos.path, 4, 0)}/config"
  ignore_absent_fields = true
  disable_delete       = true

  data_json = jsonencode({
    keytab          = var.vault_keytab
    service_account = "vault_svc"
  })
}

resource "vault_generic_endpoint" "auth_kerberos_config_ldap" {
  depends_on           = [vault_generic_endpoint.auth_kerberos_config]
  path                 = "${vault_generic_endpoint.auth_kerberos_config.path}/ldap"
  ignore_absent_fields = true
  disable_delete       = true


  data_json = jsonencode({
    url         = "ldap://dc.domain.local"
    userdn      = "DC=domain,DC=local"
    userattr    = "cn"
    upndomain   = "DOMAIN.LOCAL"
    groupattr   = "cn"
    groupdn     = "DC=domain,DC=local"
    groupfilter = "(&(objectClass=group)(member:1.2.840.113556.1.4.1941:={{.UserDN}}))"
    binddn      = "CN=vagrant-domain,CN=Users,DC=domain,DC=local"
    bindpass    = "VagrantPass1"
  })
}

resource "vault_ldap_auth_backend_group" "group" {
  depends_on = [vault_generic_endpoint.auth_kerberos_config_ldap]
  groupname  = "Domain Users"
  policies   = ["default"]
  backend    = "${substr(vault_generic_endpoint.auth_kerberos.path, 9, 0)}"
}

resource "vault_ldap_auth_backend" "ldap" {
  binddn     = "vagrant-domain@DOMAIN.LOCAL"
  bindpass   = "VagrantPass1"
  path       = "ldap"
  url        = "ldap://dc.domain.local"
  userdn     = "CN=Users,DC=domain,DC=local"
  userattr   = "sAMAccountName"
  discoverdn = true
}
