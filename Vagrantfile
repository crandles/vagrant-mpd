require 'json'

settings = JSON.parse(File.read("settings.json")).inject({}) do |new_hash, k_v|
  key, value = k_v

  new_hash[key.to_sym] = value

  new_hash
end
Vagrant::Config.run("2") do |config|
  config.vm.box = "ubuntu/trusty64"

  config.vm.network :forwarded_port, guest: 8000, host: 8000
  config.vm.network :forwarded_port, guest: 6600, host: 6600

  hostname = "mpd"
  config.vm.hostname = hostname
  config.vm.define hostname.to_sym

  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = "cookbooks"
    chef.add_recipe("mpd")
    chef.json = {
      mpd: settings
    }
  end
  
  config.vm.provider :virtualbox do |vb|
    #vb.customize ["modifyvm", :id, '--audio', 'coreaudio', '--audiocontroller', 'hda'] # choices: hda sb16 ac97
  end
end
