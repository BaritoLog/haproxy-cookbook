#
# Cookbook:: haproxy
# Recipe:: external
#
# Copyright:: 2018, BaritoLog.
#
#

haproxy_setup node[cookbook_name]['app_name'] do
  haproxy_mode            node[cookbook_name]['mode']
  global_maxconn          node[cookbook_name]['global_maxconn']
  frontend_maxconn        node[cookbook_name]['frontend_maxconn']
  custom_frontend_configs node[cookbook_name]['custom_frontend_configs']
  app_backends            node[cookbook_name]['app_backends']
  app_port                node[cookbook_name]['app_port']
  health_port             node[cookbook_name]['health_port']
  custom_backend_config   node[cookbook_name]['custom_backend_config']
  ping_url                node[cookbook_name]['ping_url']
  status_bind_address     node[cookbook_name]['status_bind_address']
  require_ssl             node[cookbook_name]['require_ssl']
  domain                  node[cookbook_name]['domain']
end
