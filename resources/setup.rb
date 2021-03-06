property :app_name,               String,   name_property: true
property :haproxy_mode,           String,   required: true
property :global_maxconn,         String,   required: true
property :status_bind_address,    String,   default: node['hostname']
property :require_ssl,            kind_of: [TrueClass, FalseClass], default: false
property :domains,                Array,    default: []
property :frontend_maxconn,       String,   required: true
property :custom_frontend_configs,Array,    default: []
property :default_backend,        String,   required: true
property :backends,               Array,    default: []
property :global_nbproc,          String,   required: true
property :global_nbthread,        String,   required: true
property :global_cpu_map,         String,   required: true

default_action :install

action :install do
  action_package_install
  action_configure_ssl if new_resource.require_ssl
  action_configure
  action_essentials
end

action :package_install do
  case node['platform_family']
  when 'debian'
    execute 'apt-get update' do
      command 'apt-get update -y'
      action :nothing
    end
  end

  package 'haproxy' do
    version '1.8.*'
    notifies :restart, "haproxy_setup[#{new_resource.app_name}]", :delayed
  end
end

action :configure_ssl do
  node.run_state[cookbook_name] ||= {}
  node.run_state[cookbook_name]['cert_paths'] = []

  new_resource.domains.each do |domain|
    pem_file = "star#{domain}.pem"
    cert_path = "/etc/ssl/#{domain}/#{pem_file}"

    directory "/etc/ssl/#{domain}/" do
      owner 'root'
      group 'root'
      mode '0755'
      recursive true
    end

    cookbook_file cert_path do
      source "haproxy/#{pem_file}"
      owner 'root'
      group 'root'
      mode '0644'
      action :create
      notifies :reload, "haproxy_setup[#{new_resource.app_name}]", :delayed
    end

    node.run_state[cookbook_name]['cert_paths'] << cert_path
  end
end

action :configure do
  cert_paths = (node.run_state.dig(cookbook_name, 'cert_paths') || [])

  template '/etc/haproxy/haproxy.cfg' do
    cookbook 'haproxy'
    source "haproxy_#{new_resource.haproxy_mode}.cfg.erb"
    owner 'root'
    group 'root'
    variables(
              app_name: new_resource.app_name,
              global_maxconn: new_resource.global_maxconn,
              global_nbproc: new_resource.global_nbproc,
              global_nbthread: new_resource.global_nbthread,
              global_cpu_map: new_resource.global_cpu_map,
              status_bind_address: new_resource.status_bind_address,
              require_ssl: new_resource.require_ssl,
              cert_paths: cert_paths,
              frontend_maxconn: new_resource.frontend_maxconn,
              custom_frontend_configs: new_resource.custom_frontend_configs,
              default_backend: new_resource.default_backend,
              backends: new_resource.backends
    )
    notifies :reload, "haproxy_setup[#{new_resource.app_name}]", :delayed
  end
end

action :essentials do
  cookbook_file '/etc/rsyslog.d/49-haproxy.conf' do
    cookbook 'haproxy'
    source 'haproxy/49-haproxy.conf'
    owner 'root'
    group 'root'
    mode '0644'
    action :create
    notifies :restart, 'service[rsyslog]', :delayed
  end

  template '/etc/logrotate.d/haproxy' do
    cookbook 'haproxy'
    source 'logrotate/haproxy-splitted.erb'
    owner 'root'
    group 'root'
    mode '0644'
  end

  execute 'run logrotate every hour' do
    command 'cp /etc/cron.daily/logrotate /etc/cron.hourly'
    not_if { ::File.exists? '/etc/cron.hourly/logrotate' }
  end

  remote_directory '/etc/haproxy/errors' do
    cookbook 'haproxy'
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
