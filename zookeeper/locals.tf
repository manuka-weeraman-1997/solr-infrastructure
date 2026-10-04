locals {
  # Renders the full ensemble's server list once, identically, into every
  # node's config - each member needs to know every other member's address.
  server_lines = join("\n", [
    for i, name in var.node_names :
    "server.${i + 1}=${var.node_ips[name]}:2888:3888"
  ])
}
