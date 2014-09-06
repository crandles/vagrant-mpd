# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run("2") do |config|

  #config.vm.box = "lucid32"
  #config.vm.box_url = "http://files.vagrantup.com/lucid32.box"
  config.vm.box = "ubuntu/trusty64"

  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = "cookbooks"
    chef.add_recipe("mpd")
    chef.json = {
      :mopidy => {
        #:spotify_username => ENV['SPOTIFY_USERNAME'],
        #:spotify_password => ENV['SPOTIFY_PASSWORD']
      }
    }
  end
  
  # config.vm.customize ["modifyvm", :id, "--audio", "coreaudio"]
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, '--audio', 'coreaudio', '--audiocontroller', 'hda'] # choices: hda sb16 ac97
  end
end
