# encoding: utf-8

# Inspec test for recipe haproxy::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe package('haproxy') do
  it { should be_installed }
end

unless os.windows?
  describe group('haproxy') do
    it { should exist }
  end

  describe user('haproxy')  do
    it { should exist }
  end
end

describe file('/etc/haproxy/haproxy.cfg') do
  its('mode') { should cmp '0644' }
end

describe file('/etc/rsyslog.d/49-haproxy.conf') do
  its('mode') { should cmp '0644' }
end

describe file('/etc/logrotate.d/haproxy') do
  its('mode') { should cmp '0644' }
end

describe file('/etc/cron.hourly/logrotate') do
  its('mode') { should cmp '0755' }
end

describe systemd_service('haproxy') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end
