require "serverspec"

set :backend, :exec

describe service("sogod") do
  it { should be_enabled }
  it { should be_running }
end

describe port("80") do
  it { should be_listening }
end

describe command("curl -L localhost/SOGo") do
  its(:stdout) { should match /SOGo/ }
end
