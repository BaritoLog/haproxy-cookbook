#
# Cookbook:: haproxy
# Recipe:: internal
#
# Copyright:: 2018, BaritoLog.
#
#

haproxy_setup node[cookbook_name]['app_name'] do
  haproxy_mode            node[cookbook_name]['mode']
  global_maxconn          node[cookbook_name]['global_maxconn']
  global_nbproc           node[cookbook_name]['global_nbproc']
  global_nbthread         node[cookbook_name]['global_nbthread']
  global_cpu_map          node[cookbook_name]['global_cpu_map']
  status_bind_address     node[cookbook_name]['status_bind_address']
  frontend_maxconn        node[cookbook_name]['frontend_maxconn']
  custom_frontend_configs node[cookbook_name]['custom_frontend_configs']
  default_backend         node[cookbook_name]['default_backend']
  backends                node[cookbook_name]['backends']
end
