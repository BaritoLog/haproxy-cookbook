#
# Cookbook:: haproxy
# Attribute:: default
#
# Copyright:: 2018, BaritoLog.
#
#

cookbook_name = 'haproxy'

default[cookbook_name]['app_name']                = 'test'
default[cookbook_name]['mode']                    = 'http'
default[cookbook_name]['global_maxconn']          = '10000'
default[cookbook_name]['frontend_maxconn']        = '10000'
default[cookbook_name]['custom_frontend_configs'] = []

# app_backends format: [{host: 'aa.bb.cc.dd', maxconn: 32}]
default[cookbook_name]['app_backends']            = []

default[cookbook_name]['app_port']                = 80
default[cookbook_name]['health_port']             = 80
default[cookbook_name]['custom_backend_config']   = ''
default[cookbook_name]['ping_url']                = '/ping'
default[cookbook_name]['status_bind_address']     = node['hostname']
default[cookbook_name]['require_ssl']             = false
default[cookbook_name]['domain']                  = 'test-domain.com'
