#!/bin/bash
# By PinkLure 2022.11.11

function display_help() {
  echo "Usage: $0 [option...] " >&2
  echo " -d | --drive path_to_drive"
  echo " -D | --debug"
  echo " -G | --graphic"
  echo " -h | --help"
  echo " -k | --kernel path_to_kernel"
  echo " -K | --kvm"
  echo " -L | --log logfile"
  echo " -M | --memory memory_size"
  echo " -P | --pidfile pidfile_name"
  echo " -S | --smp core_number"
}

if [ $# -eq 0 ]; then
  display_help
  exit 255
fi

KERNEL=""
DRIVE=""

QEMU_DEBUG=false
QEMU_GRAPHIC=false
QEMU_KVM=false
QEMU_LOGFILE="vm.log"
QEMU_MEMORY="2G"
QEMU_OPTIONS_APPEND="console=ttyS0 root=/dev/sda earlyprintk=serial net.ifnames=0 nokaslr"
QEMU_OPTIONS="-net user,host=10.0.2.10,hostfwd=tcp:127.0.0.1:10021-:22 -net nic,model=e1000"

#echo $QEMU_OPTIONS

QEMU_PIDFILE="vm.pid"
QEMU_SMP=2

while true; do
  if [ $# -eq 0 ]; then
    break
  fi

  case "$1" in
    -d | --drive)
      DRIVE=$2
      shift 2
      ;;
    -D | --debug)
      QEMU_DEBUG=true
      shift 1
      ;;
    -G | --graphic)
      QEMU_GRAPHIC=true
      shift 1
      ;;
    -h | --help)
      display_help
      exit 0
      ;;
    -k | --kernel)
      KERNEL=$2
      shift 2
      ;;
    -K | --kvm)
      QEMU_KVM=true
      shift 1
      ;;
    -L | --log)
      QEMU_LOGFILE=$2
      shift 2
      ;;
    -M | --memory)
      QEMU_MEMORY=$2
      shift 2
      ;;
    -P | --pidfile)
      QEMU_PIDFILE=$2
      shift 2
      ;;
    -S | --smp)
      QEMU_SMP=$2
      shift 2
      ;;
    -*)
      echo "Error: Unknown option: $1" >&2
      exit 1
      ;;
    *) # No more options
      break
      ;;
  esac
done

function assert_non_empty() {
  for var in "$@"
  do
    if [ -z "${var}" ]; then
      display_help
      exit 255
    fi
  done
}

assert_non_empty $KERNEL $DRIVE

echo "KERNEL : ${KERNEL}"
echo "DRIVE : ${DRIVE}"

if ${QEMU_DEBUG} ;then
  QEMU_OPTIONS="${QEMU_OPTIONS} -s -S"
fi

if ! ${QEMU_GRAPHIC} ;then
  QEMU_OPTIONS="${QEMU_OPTIONS} --nographic"
fi

if ${QEMU_KVM} ;then
  QEMU_OPTIONS="${QEMU_OPTIONS} --enable-kvm"
fi


QEMU_OPTIONS="${QEMU_OPTIONS} -m ${QEMU_MEMORY} -smp ${QEMU_SMP} -pidfile ${QEMU_PIDFILE} -kernel $KERNEL -drive file=$DRIVE,format=raw -append "\"${QEMU_OPTIONS_APPEND}\"" 2>&1 | tee ${QEMU_LOGFILE}"

eval "qemu-system-x86_64 ${QEMU_OPTIONS}"