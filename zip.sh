#!/bin/bash

if [[ -z "$1" ]]; then
     echo "NO <ENV_NAME>"
#    echo "USAGE: $0 ENV_NAME"
    exit 1
fi

env_name="$1"

rm -f $env_name".tar.*"

#Path where configuration xmls of VMs whill be saves
node_path=~/node_xml_save
#Path where configuration xmls of networks will be saved
net_path=~/network_xml_save/
#Path where configuration xmls of snapshots will be saved
snapshot_path=~/snapshot_xml_save/
GZ=`which pigz || which gzip`
mkdir -p ~/network_xml_save
mkdir -p ~/node_xml_save
mkdir -p ~/snapshot_xml_save

echo 'VM snapshot creation'
nodes=(`virsh list --all | awk '{print $2}' | sed  -n "/^$env_name/p"`) 
echo ${#nodes[*]}
for i in ${nodes[@]} ; do
    virsh snapshot-create-as ${i} ${i}_$(date '+%Y-%m-%d-%H-%M')
    echo "${i} is  Ready"
    virsh dumpxml ${i} > $node_path/node_snapshot_${i}.xml
    echo "${i} is  Ready"
    snapshots=(`virsh snapshot-list ${i} | tail -f | awk '{print $1}'| sed  -n "/^$env_name/p"`)
    virsh snapshot-dumpxml ${i} $snapshots > $snapshot_path/$snapshots.xml    
done

echo 'Network .xmls save' 
nets=(`virsh net-list --all | awk '{print $1}' | sed  -n "/$env_name/p"`)
echo ${#nets[*]}
for i in ${nets[@]} ; do
    virsh net-dumpxml ${i} > $net_path/net_snapshot_${i}.xml 
    echo "${i} is Ready"
done

list=($(ls -1 ~/node_xml_save | tail -f -n 1))
echo 'Creation of archive'
vm_path_one=$(egrep "source file" $node_path/$list | cut -d "'" -f 2 | xargs dirname)
>>$env_name.tar
containers=(`ls -l $vm_path_one | awk '{print $9}' | sed  -n "/^$env_name/p"`)
echo 'Images number:'${#containers[*]}
for i in ${containers[@]} ; do
    tar --append -f $env_name.tar $vm_path_one/${i} 
done
tar --append -f $env_name.tar $net_path $node_path $snapshot_path
$GZ -1 $env_name.tar
#Clening section
rm -rf $net_path # Cleaning dir "~/network_xml_save"
rm -rf $node_path   # Cleaning dir "~/node_xml_save"
rm -rf $snapshot_path #Cleaning dir "~/snapshot_xml_save"
echo "-=DONE=-"
