#!/bin/sh

export vmMaster="/Users/davidross/Virtual Machines.localized/k8s126m.vmwarevm/k8s126m.vmx"
export vmNode01="/Users/davidross/Virtual Machines.localized/k8s126n1.vmwarevm/k8s126n1.vmx"
export vmNode02="/Users/davidross/Virtual Machines.localized/k8s126n2.vmwarevm/k8s126n2.vmx"

case "$1" in
start)
	vmrun -T ws start "$vmMaster" nogui && sleep 10
	vmrun -T ws start "$vmNode01" nogui
	vmrun -T ws start "$vmNode02" nogui
	;;
stop)
	vmrun -T ws stop "$vmMaster" nogui
	vmrun -T ws stop "$vmNode01" nogui
	vmrun -T ws stop "$vmNode02" nogui
	;;
suspend)
	vmrun -T ws suspend "$vmMaster" nogui
	vmrun -T ws suspend "$vmNode01" nogui
	vmrun -T ws suspend "$vmNode02" nogui
	;;
pause)
	vmrun -T ws pause "$vmMaster" nogui
	vmrun -T ws pause "$vmNode01" nogui
	vmrun -T ws pause "$vmNode02" nogui
	;;
unpause)
	vmrun -T ws unpause "$vmMaster" nogui
	vmrun -T ws unpause "$vmNode01" nogui
	vmrun -T ws unpause "$vmNode02" nogui
	;;
reset)
	vmrun -T ws reset "$vmMaster" nogui
	vmrun -T ws reset "$vmNode01" nogui
	vmrun -T ws reset "$vmNode02" nogui
	;;
snap)
	if [ "$#" -ne 2 ]; then
		echo "Illegal number of parameters"
		exit 2
	fi

	vmrun -T ws snapshot "$vmMaster" "$2"
	vmrun -T ws snapshot "$vmNode01" "$2"
	vmrun -T ws snapshot "$vmNode02" "$2"
	;;
restoreSnap)
	if [ "$#" -ne 2 ]; then
		echo "Illegal number of parameters"
		exit 2
	fi

	vmrun -T ws revertToSnapshot "$vmMaster" "$2"
	vmrun -T ws revertToSnapshot "$vmNode01" "$2"
	vmrun -T ws revertToSnapshot "$vmNode02" "$2"
	;;
deleteSnap)
	if [ "$#" -ne 2 ]; then
		echo "Illegal number of parameters"
		exit 2
	fi

	vmrun -T ws deleteSnapshot "$vmMaster" "$2"
	vmrun -T ws deleteSnapshot "$vmNode01" "$2"
	vmrun -T ws deleteSnapshot "$vmNode02" "$2"
	;;

listSnaps)
	echo "VM: $vmMaster" && vmrun -T ws listSnapshots "$vmMaster" 
	echo "VM: $vmNode01" && vmrun -T ws listSnapshots "$vmNode01"
	echo "VM: $vmNode02" && vmrun -T ws listSnapshots "$vmNode02"
	;;

status)
	vmrun list
	;;
    *)
        cat << END_USAGE1
Usage: ${0} {option}
    where {option} affects both VMs at the same time:
        Operations:
                start           - start (no GUI)
                stop            - stop
                suspend         - suspend
                pause           - pause
                unpause         - unpause
                reset           - reset (hard power off)
                status          - list running VMs
        Snapshots:
                For all but listSnaps, provide the snapshot name as the second parameter
                snap            - create a snapshot
                                        e.g., ${0} snap mySnapshotName
                restoreSnap     - revert to snapshot
                                        e.g., ${0} restoreSnap mySnapshotName
                deleteSnap      - delete a snapshot
                                        e.g., ${0} deleteSnap mySnapshotName
                listSnaps       - list snapshots for each VM
END_USAGE1
        exit 1
        ;;
esac
