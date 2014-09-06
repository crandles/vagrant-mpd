# execute "initial sound config" do
#   command <<-EOF
#   set -e # Stop on any error

#   # --------------- SETTINGS ----------------
#   # Other settings
#   export DEBIAN_FRONTEND=noninteractive

#   sudo apt-get update

#   # ---- OSS AUDIO
#   sudo usermod -a -G audio vagrant
#   sudo apt-get install -y oss4-base oss4-dkms oss4-source oss4-gtk debconf-utils
#   sudo ln -s /usr/src/linux-headers-$(uname -r)/ /lib/modules/$(uname -r)/source || echo ALREADY SYMLINKED
#   sudo module-assistant prepare
#   sudo module-assistant auto-install -i oss4 # this can take 2 minutes
#   sudo debconf-set-selections <<< "linux-sound-base linux-sound-base/sound_system select  OSS"
#   echo READY.

#   # have to reboot for drivers to kick in, but only the first time of course
#   if [ ! -f ~/runonce ]
#   then
#     sudo reboot
#     touch ~/runonce
#   fi
# EOF
#   action :run
# end

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

template "/etc/auto.media-shares" do
  source "networkshare.erb"
  mode 0644
  owner "root"
  group "root"
  variables(
    :ntfs_ip => "10.0.0.12",
    :ntfs_share =>"Public",
    :username => "admin", :password => "tylertyler"
  )
end

template "/etc/auto.master" do
  source "auto.master.erb"
  mode 0644
  owner "root"
  group "root"
end

execute "create autofs dir" do
  command "sudo service autofs restart"
  command "ls /media/shares/music"
  command "ls /media/shares/"
  returns [0, 1]
  action :run
end
=begin
  sudo apt-get install autofs -y
sudo apt-get install samba-client -y
sudo apt-get install cifs-utils
sudo cp /vagrant_files/auto.master /etc/auto.master
sudo cp /vagrant_files/auto.media-shares /etc/auto.media-shares
sudo service autofs restart
ls /media/shares/music/
ls /media/shares/Home/Music
ln -nsf /media/shares/Home/Music /var/lib/mopidy/media/music
=end


### Setup NAS

### Setup MPD
apt_package "mpd"

#### MPD CLIENT ####
apt_package "mpc"


#### SYSTEM AUDIO SETUP ####
apt_package "linux-sound-base"
apt_package "alsa"
apt_package "alsa-utils"

system_username = node[:mpd][:system_user]

execute "add current user to audio group" do
  command "sudo usermod -a -G audio #{system_username}"
  action :run
end

# execute "more power" do
#   command <<-EOS
#     amixer -c 0 set Master playback 100% unmute
#     amixer -c 0 set Headphone playback 100% unmute
#     amixer -c 0 set Speaker playback 100% unmute
#   EOS
#   action :run
# end





# ### UPDATE APT ###
# execute "Setup Mopidy APT archive" do
#   command <<-EOH
#     wget -q -O - http://apt.mopidy.com/mopidy.gpg | sudo apt-key add -
#     sudo wget -q -O /etc/apt/sources.list.d/mopidy.list http://apt.mopidy.com/mopidy.list
#   EOH
#   action :run
# end

# execute "Update APT" do
#   command "sudo apt-get update"
#   #command "sudo apt-get upgrade -y"
#   action :run
# end

# apt_package "python-software-properties"

# execute "Add python PPA" do
#   command "sudo add-apt-repository ppa:fkrull/deadsnakes"
#   command "sudo apt-get update"
# end
# ### INSTALL USEFUL SERVER TOOLS ###
# include_recipe "build-essential"
# apt_package "vim"

# #### MOPIDY DEPENDENCIES ####
# include_recipe "python"

# bash "Install pykka" do
#   code "sudo pip install -U pykka"
#   action :run
# end

# package "python-gst0.10"

# apt_package "python2.7"

# apt_package "python-dev"

# apt_package "gstreamer0.10-alsa"
# apt_package "gstreamer0.10-plugins-good"
# apt_package "gstreamer0.10-plugins-ugly"
# apt_package "gstreamer0.10-tools"
# apt_package "python-spotify"

# bash "Upgrade APT" do
#   code "sudo apt-get update"
#   #code "sudo apt-get upgrade -y"
#   action :run
# end

# #### INSTALL MOPIDY ####
# #execute "Install latest dev version of Mopidy" do
#   apt_package "mopidy"
#   #action :run
# #end

# #### MOPIDY CONFIG ####
# system_username = node[:mopidy][:system_user]

# bash "create mopidy config directory" do
#   code "mkdir -p /home/#{system_username}/.config/mopidy"
#   action :run
# end

# template "/home/#{system_username}/.config/mopidy/settings.py" do
#   source "settings.py.erb"
#   mode 0644
#   owner system_username
#   group system_username
#   variables(
#     :spotify_username => node[:mopidy][:spotify_username],
#     :spotify_password => node[:mopidy][:spotify_password]
#   )
# end

# bash "create mopidy logfile" do
#   code "touch /var/log/mopidy.log && chmod 644 /var/log/mopidy.log && chown #{system_username}:root /var/log/mopidy.log"
#   action :run
# end

# template "/etc/init/mopidy.conf" do
#   source "mopidy.conf.erb"
#   mode 0644
#   owner "root"
#   group "root"
#   variables(
#     :mopidy_username => system_username,
#     :mopidy_log_path => "/var/log/mopidy.log"
#   )
# end

