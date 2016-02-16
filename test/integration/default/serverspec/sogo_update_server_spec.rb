require "serverspec"

set :backend, :exec

describe command("curl -L localhost/mozilla-plugins/updates.php?plugin=plugin-not-found") do
  its(:stdout) { should match /Plugin not found/ }
end

describe command("curl -L localhost/mozilla-plugins/updates.php?plugin=sogo-connector@inverse.ca") do
  its(:stdout) { should match /updateLink/ }
end

describe command("curl -L localhost/mozilla-plugins/updates.php?plugin=sogo-integrator@inverse.ca") do
  its(:stdout) { should match /updateLink/ }
end
