property :app_name,               String,   name_property: true
property :haproxy_mode,           String,   required: true
property :global_maxconn,         String,   required: true
property :frontend_maxconn,       String,   required: true
property :custom_frontend_configs,Array,    default: []
property :app_backends,           Array,    default: []
property :app_port,               Integer,  required: true
property :health_port,            Integer
property :custom_backend_config,  String,   default: ''
property :ping_url,               String,   default: ''
property :status_bind_address,    String,   default: node['hostname']
property :require_ssl,            kind_of: [TrueClass, FalseClass], default: false
property :domain,                 String

default_action :install

action :install do
  action_package_install
  action_configure
  action_essentials
end

action :package_install do
  case node['platform_family']
  when 'debian'
    apt_repository 'haproxy' do
      uri 'ppa:vbernat/haproxy-1.6'
      distribution node['lsb']['codename']
      notifies :run, 'execute[apt-get update]', :immediately
    end

    execute 'apt-get update' do
      command 'apt-get update -y'
      action :nothing
    end
  end

  package 'haproxy' do
    notifies :restart, "haproxy_setup[#{new_resource.app_name}]", :delayed
  end

  if new_resource.require_ssl
    action_configure_ssl
  end
end

action :configure_ssl do
  pem_file = "star#{new_resource.domain}.pem"
  cert_path = "/etc/ssl/#{new_resource.domain}/#{pem_file}"

  directory "/etc/ssl/#{new_resource.domain}/" do
    owner 'root'
    group 'root'
    mode '0755'
    recursive true
  end

  cookbook_file cert_path do
    source "haproxy/#{pem_file}"
    cookbook 'haproxy'
    owner 'root'
    group 'root'
    mode '0644'
    action :create
    notifies :reload, "haproxy_setup[#{new_resource.app_name}]", :delayed
  end
end

action :configure do
  pem_file = "star#{new_resource.domain}.pem"
  cert_path = "/etc/ssl/#{new_resource.domain}/#{pem_file}"

  template '/etc/haproxy/haproxy.cfg' do
    source "haproxy_#{new_resource.haproxy_mode}.cfg.erb"
    owner 'root'
    group 'root'
    variables(
              app_name: new_resource.app_name,
              global_maxconn: new_resource.global_maxconn,
              frontend_maxconn: new_resource.frontend_maxconn,
              custom_frontend_configs: new_resource.custom_frontend_configs,
              app_backends: new_resource.app_backends,
              app_port: new_resource.app_port,
              health_port: new_resource.health_port || new_resource.app_port,
              custom_backend_config: new_resource.custom_backend_config,
              ping_url: new_resource.ping_url,
              status_bind_address: new_resource.status_bind_address,
              require_ssl: new_resource.require_ssl,
              cert_path: cert_path
    )
    notifies :reload, "haproxy_setup[#{new_resource.app_name}]", :delayed
  end
end

action :essentials do
  cookbook_file '/etc/rsyslog.d/49-haproxy.conf' do
    source 'haproxy/49-haproxy.conf'
    cookbook 'haproxy'
    owner 'root'
    group 'root'
    mode '0644'
    action :create
    notifies :restart, 'service[rsyslog]', :delayed
  end

  template '/etc/logrotate.d/haproxy' do
    source 'logrotate/haproxy-splitted.erb'
    cookbook 'haproxy'
    owner 'root'
    group 'root'
    mode '0644'
  end

  execute 'run logrotate every hour' do
    command 'cp /etc/cron.daily/logrotate /etc/cron.hourly'
    not_if { ::File.exists? '/etc/cron.hourly/logrotate' }
  end

  remote_directory '/etc/haproxy/errors' do
    source 'haproxy/errors'
    owner 'root'
    group 'root'
    mode '0755'
    action :create
    notifies :reload, "haproxy_setup[#{new_resource.app_name}]", :delayed
  end

  service 'rsyslog' do
    action :nothing
    supports status: true, start: true, stop: true, restart: true
  end
end

action :reload do
  service 'haproxy' do
    action [:enable, :reload]
    supports status: true, start: true, stop: true, restart: true, reload: true
  end
end

action :restart do
  service 'haproxy' do
    action [:enable, :restart]
    supports status: true, start: true, stop: true, restart: true, reload: true
  end
end
