#
# Cookbook:: haproxy
# Attribute:: default
#
# Copyright:: 2018, BaritoLog.
#
#

cookbook_name = 'haproxy'

default[cookbook_name]['app_name']                = 'default'
default[cookbook_name]['mode']                    = 'http'
default[cookbook_name]['global_maxconn']          = '10000'
default[cookbook_name]['status_bind_address']     = node['hostname']

# Frontend configurations
default[cookbook_name]['require_ssl']             = false
default[cookbook_name]['domains']                 = []
default[cookbook_name]['frontend_maxconn']        = '10000'
default[cookbook_name]['custom_frontend_configs'] = []
default[cookbook_name]['default_backend']         = 'default-backend'

# Backend configurations
# 
# Sample:
#
# default[cookbook_name]['backends']                = [
#   {
#     name: 'default-backend', 
#     ping_url: '/ping',
#     servers: [{host: 'aa.bb.cc.dd', maxconn: 32}],
#     app_port: 80,
#     health_port: 80,
#     custom_backend_config: ''
#   }
# ]
#
default[cookbook_name]['backends']                = []
