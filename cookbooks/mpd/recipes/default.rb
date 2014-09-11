
### Useful functions
def apt_update
  execute "APT Update" do
    command "sudo apt-get update"
    action :run
  end
end

### Update APT
apt_update

### Set up autofs
apt_package "autofs"
apt_package "samba-client"
apt_package "cifs-utils"

### Configure autofs
# execute "create autofs dir" do
#   command "mkdir -p /etc/auto.master.d"
#   action :run
# end

template "/etc/auto.media-share" do
  source "networkshare.erb"
  mode 0644
  owner "root"
  group "root"
  variables(
    :ntfs_ip => node[:mpd][:remote_ip],
    :ntfs_share => node[:mpd][:remote_share],
    :username => node[:mpd][:remote_user], :password => node[:mpd][:remote_password]
  )
  # notifies :restart, resources(:service => "autofs")
end

template "/etc/auto.master" do
  source "auto.master.erb"
  mode 0644
  owner "root"
  group "root"
  # notifies :restart, resources(:service => "autofs")
end

execute "restart autofs" do
  command "sudo service autofs restart"
  action :run
end

execute "ls music share" do
  command "ls /media/remote/music/"
  returns [0, 1, 2]
end

### Setup Icecast2

apt_package "icecast2"
template "/etc/default/icecast2" do
  source "default_icecast2.erb"
  mode 0644
  owner "root"
  group "root"
  # notifies :restart, resources(:service => "icecast2")
end
template "/etc/icecast2/icecast.xml" do
  source "icecast2.xml.erb"
  mode 0644
  owner "root"
  group "root"
  # notifies :restart, resources(:service => "icecast2")
end

### Setup MPD
apt_package "mpd"
apt_package "mpc"

template "/etc/mpd.conf" do
  source "mpd.conf.erb"
  mode 0644
  owner "root"
  group "root"
  variables(
    :remote_music_dir => node[:mpd][:remote_music_dir]
  )
end

bash "restore mpd database" do
  user "root"
  code <<-EOL
    mpc # trigger the state file to be generated on next start.
    sudo service mpd stop # Stop MPD before replacing its contents!
    if [ -d '/vagrant/data/mpd' ]; then sudo cp -r /vagrant/data/mpd /var/lib; fi
    sudo chown -R mpd:audio /var/lib/mpd/
    sudo chown -R mpd:audio /var/log/mpd/
  EOL
end



execute "restart services" do
  user "root"
  code <<-EOL
    sudo service icecast2 restart
    sudo service mpd start
    mpc
    sudo service mpd restart
  EOL
  returns [0,1]
end



### File Watchers
apt_package "incron"

execute "configure incron" do
  command "rm -f /etc/incron.allow"
  action :run
end

template "/etc/incron.d/mpd" do
  source "incron.mpd.erb"
  mode 0644
  owner "root"
  group "root"
end


#### SYSTEM AUDIO SETUP ####
apt_package "linux-sound-base"
apt_package "alsa"
apt_package "alsa-utils"

system_username = node[:mpd][:system_user]

execute "add current user to audio group" do
  command "sudo usermod -a -G audio #{system_username}"
  action :run
end