# Enable transit secrets engine
path "sys/mounts/transit" {
  capabilities = [ "read", "update", "list" ]
}

# To read enabled secrets engines
path "sys/mounts" {
  capabilities = [ "create", "read", "update", "delete" ]
}

# Manage the keys transit keys endpoint
path "transit/keys/<namespace>-<env>-pingfederate" {
  capabilities = [ "create", "read", "update", "list" ]
}

# Manage the keys transit keys endpoint
path "transit/encrypt/<namespace>-<env>-pingfederate" {
  capabilities = [ "create", "read", "update", "list" ]
}

# Manage the keys transit keys endpoint
path "transit/decrypt/<namespace>-<env>-pingfederate" {
  capabilities = [ "create", "read", "update", "list" ]
}

#Manage the cubbyhole secrets engine
path "cubbyhole/<namespace>/<env>/pingfederate/masterkey" {
  capabilities = [ "create", "read", "update", "list" ]
}
