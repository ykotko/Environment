#!/bin/bash


if [[ -z "$1" ]]; then
     echo "NO <ENV_NAME>"
#    echo "USAGE: $0 ENV_NAME"
    exit 1
fi

env_name="$1"
#Path where configuration xmls of VMs whill be saves
node_path=~/node_xml_save
#Path where configuration xmls of networks will be saved
net_path=~/network_xml_save


echo 'Unzip archive'
tar -xvzf $env_name.tar.gz -C /

echo 'Define NET'
nets=(`ls -l $net_path | awk '{print $9}'`)
echo ${#nets[*]}
for i in ${nets[@]} ; do
    virsh net-define $net_path/${i}
done
nets_start=(`virsh net-list --all | awk '{print $1}' | sed  -n "/$env_name/p"`)
for i in ${nets_start[@]} ; do
virsh net-start ${i}
virsh net-autostart ${i}
done


rm -rf $net_path # Cleaning dir "~/network_xml_save"


echo 'Define VM'
nodes=(`ls -l $node_path | awk '{print $9}'`)
echo ${#nodes[*]}
for i in ${nodes[@]} ; do
    virsh define $node_path/${i}
done
node_start=(`virsh list --all | awk '{print $2}' | sed  -n "/^$env_name/p"`)
for i in ${node_start[@]} ; do
virsh start ${i}
virsh autostart ${i}
done

rm -rf $node_path

##############################################################################################
echo 'Snapshot reverting'
for i in ${node_start[@]};do
snapshot_list=(`virsh snapshot-list ${i} | awk '{print $1}' | sed  -n "/^snapshot/p"`)
#snapshot_list=(`virsh snapshot-list ${i} | tailf -n 2 |awk '{print $1}' | sed  -n "/^snapshot/p"`)
virsh snapshot-revert ${i} $snapshot_list
done

