# pve-clustercron
Simple attempt at creating cluster wide cron jobs


Useful for running UserManager (pveum) syncs and such.

# Install
Run on any proxmox node:
```
  # git clone https://github.com/conraythefirst/pve-clustercron.git
  # cd pve-clustercron/
  # cp -r pve-clustercron/ /etc/pve/
```
Run on each proxmox node:
```
  # ln -s /etc/pve/clustercron/clustercron.cron /etc/cron.d/pve-clustercron
```

Now add your cron jobs to /etc/pve/clustercron/clustercron.cron
Prefix your commands with "bash /etc/pve/clustercron/clustercron.sh isactive && " to only run on the master node.
```
  15 * * * *           root bash /etc/pve/clustercron/clustercron.sh isactive && my-cron
```



# Usage clustercron.sh
'''
clustercron.sh [select|status|isactive]
    select   - select master node
               if HA is configured then ha-manager is used
               otherwise it's selected by random 
    status   - return current master node
    isactive - return ture if master, false if not

'''


