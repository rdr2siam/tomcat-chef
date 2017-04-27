# # encoding: utf-8

# Inspec test for recipe tomcat-chef::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe service('tomcat') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe command 'curl localhost:8080' do
  its('stdout') { should match /tomcat/ }
end

describe port (8080) do
  it { should be_listening }
end
