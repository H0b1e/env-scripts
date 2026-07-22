#!/bin/bash

print_help0="Usage:     $0 <from DB path> <to DB path> [-debug] [-readback] [-all]"

[[ "$*" =~ '-h' ]] && echo $print_help0 && exit

if [ ! -z "$1" ] ; then
	from=$1
else
	echo "Please specify path where the runtime DB from."
    echo $print_help0
	exit 1
fi

if [ ! -z "$2" ] ; then
	to=$2
else
	echo "Please specify path where the runtime DB extract to."
    echo $print_help0
	exit 1
fi

if [ ! -d $from/DB/Runtime ] ; then
	echo "Please specify correct path where the runtime DB from: '$from'"
    echo $print_help0
	exit 1
fi
myargs="$*"
[[ "$myargs" =~ '-debug' ]] && debug_db=true
[[ "$myargs" =~ '-readb' ]] && readback=true
[[ "$myargs" =~ '-force' ]] && force_cp=true
[[ "$myargs" =~ '-all' ]]   && all_opti=true
# [ $all_opti ] && echo all_opti=true
# [ $force_cp ] && echo force_cp=true
# [ $readback ] && echo readback=true
# [ $debug_db ] && echo debug_db=true
if [ -e $to ] ; then
	if [ $force_cp ] ; then 
		echo "The runtime DB dir '$to' exist."
		echo "It will be overwritten as user specified '-force'."
		rm -rf $to
	else
		echo "The runtime DB dir '$to' exist. Please specify a new diretory!"
		exit 1
	fi
fi
#echo $0 $1 $2
echo "Extract Runtime DB ..."

if [[ ! $all_opti  && ! $debug_db ]]; then
    echo "Warning: debug information is not included!  Please add '-debug' or '-all' option if the information is required."
fi
if [[ ! $all_opti  && ! $readback ]]; then
    echo "Warning: readback information is not included! Please add '-readback' or '-all' option if the information is required."
fi

[ ! -d "$to/DB/Names" ] && mkdir -p "$to/DB/Names"
[ ! -d "$to/DB/Runtime/uvrtdb" ] && mkdir -p "$to/DB/Runtime/uvrtdb"
[ ! -d "$to/Synthesis/Dpi" ] && [ -d "$from/Synthesis/Dpi" ] && mkdir -p "$to/Synthesis/Dpi"
[ ! -d "$to/Synthesis/Hw_mem" ] && [ -d "$from/Synthesis/Hw_mem" ] &&  mkdir -p "$to/Synthesis/Hw_mem"
[ ! -d "$to/Synthesis/Hw_mem/Script" ] && mkdir -p "$to/Synthesis/Hw_mem/Script"
[ -e $from/Log/targetsystem.dcf ] && cp $from/Log/targetsystem.dcf $to/DB/

if [ $all_opti ];then
    echo "All debug and readback information is included!"
    [ -e $from/Uvd ] && cp -rf $from/Uvd $to/
    [ -e $from/Synthesis/Dpi/C ] && cp -rf $from/Synthesis/Dpi/C $to/Synthesis/Dpi
    [ -e $from/DB/Options ] && cp -rf $from/DB/Options $to/DB/
    [ -e $from/DB/Linkage ] && cp -rf $from/DB/Linkage $to/DB/
    [ -e $from/DB/Sys_Design ] && cp -rf $from/DB/Sys_Design $to/DB/
    [ -e $from/DB/Names ] && cp -rf $from/DB/Names $to/DB/
    [ -e $from/DB/Runtime/uvrtdb/sec.* ] && cp -rf $from/DB/Runtime/uvrtdb/sec.* $to/DB/Runtime/uvrtdb/
    [ -e $from/DB/Runtime/uvrtdb/runtime.* ] && cp -rf $from/DB/Runtime/uvrtdb/runtime.* $to/DB/Runtime/uvrtdb/
    [ -e $from/DB/Runtime/uvrtdb/.runtime.* ] && cp -rf $from/DB/Runtime/uvrtdb/.runtime.* $to/DB/Runtime/uvrtdb/
    [ -e $from/DB/Runtime/uvrtdb/uvrtdb.hash ] && cp -f $from/DB/Runtime/uvrtdb/uvrtdb.hash $to/DB/Runtime/uvrtdb/
    [ -e $from/DB/Runtime/uvrtdb/debug.* ] && cp -rf $from/DB/Runtime/uvrtdb/debug.* $to/DB/Runtime/uvrtdb/
    [ -e $from/DB/Runtime/uvrtdb/mem.* ] && cp -f $from/DB/Runtime/uvrtdb/mem.* $to/DB/Runtime/uvrtdb/
    [ -e $from/DB/Runtime/uvrtdb/rtl2gate.* ] && cp -rf $from/DB/Runtime/uvrtdb/rtl2gate.* $to/DB/Runtime/uvrtdb/
    [ -e $from/DB/Runtime/uvrtdb/signal ] && cp -rf $from/DB/Runtime/uvrtdb/signal $to/DB/Runtime/uvrtdb/
    [ -e $from/DB/Runtime/uvrtdb/coord ] && cp -rf $from/DB/Runtime/uvrtdb/coord $to/DB/Runtime/uvrtdb/
    [ -e $from/DB/Runtime/uvrtdb/rb ] && cp -rf $from/DB/Runtime/uvrtdb/rb $to/DB/Runtime/uvrtdb/
    [ -e $from/DB/Runtime/uvrtdb/fv ] && cp -rf $from/DB/Runtime/uvrtdb/fv $to/DB/Runtime/uvrtdb/
    [ -e $from/DB/Runtime/uvrtdb/rr ] && cp -rf $from/DB/Runtime/uvrtdb/rr $to/DB/Runtime/uvrtdb/
    [ -e $from/DB/Runtime/uvrtdb/ffvd ] && cp -rf $from/DB/Runtime/uvrtdb/ffvd $to/DB/Runtime/uvrtdb/
    [ -e $from/DB/Runtime/glsgraph ] && cp -f $from/DB/Runtime/glsgraph $to/DB/Runtime/
    [ -e $from/DB/Runtime/glsgraphgz ] && cp -f $from/DB/Runtime/glsgraphgz $to/DB/Runtime/
    [ -e $from/DB/Runtime/.glsgraphgz.dir ] && cp -rf $from/DB/Runtime/.glsgraphgz.dir $to/DB/Runtime/
    [ -e $from/DB/Runtime/.glsgraphgz.config ] && cp -f $from/DB/Runtime/.glsgraphgz.config $to/DB/Runtime/
    [ -e $from/DB/Runtime/nocoord.rtdb ] && cp -rf $from/DB/Runtime/nocoord.rtdb $to/DB/Runtime/
    [ -e $from/DB/Runtime/waveconvdb.dat ] && cp -rf $from/DB/Runtime/waveconvdb.dat $to/DB/Runtime/
    [ -e $from/DB/Runtime/.waveconvdb.dat.dir ] && cp -rf $from/DB/Runtime/.waveconvdb.dat.dir $to/DB/Runtime/
    [ -e $from/DB/Runtime/.waveconvdb.dat.config ] && cp -f $from/DB/Runtime/.waveconvdb.dat.config $to/DB/Runtime/
    [ -e $from/Synthesis/Hw_mem/Script/runtime_init.tcl ] && cp -rf $from/Synthesis/Hw_mem/Script/runtime_init.tcl $to/Synthesis/Hw_mem/Script/
    [ -e $from/Synthesis/Hw_mem/Init ] && cp -rf $from/Synthesis/Hw_mem/Init $to/Synthesis/Hw_mem/
else 
    [ -e $from/Synthesis/Dpi/C ] && cp -rf $from/Synthesis/Dpi/C $to/Synthesis/Dpi
    [ -e $from/DB/Options ] && cp -rf $from/DB/Options $to/DB/
    [ -e $from/DB/Linkage ] && cp -rf $from/DB/Linkage $to/DB/
    [ -e $from/DB/Sys_Design ] && cp -rf $from/DB/Sys_Design $to/DB/
    [ -e $from/DB/Runtime/uvrtdb/sec.* ] && cp -rf $from/DB/Runtime/uvrtdb/sec.* $to/DB/Runtime/uvrtdb/
    [ -e $from/DB/Runtime/uvrtdb/runtime.* ] && cp -rf $from/DB/Runtime/uvrtdb/runtime.* $to/DB/Runtime/uvrtdb/
    [ -e $from/DB/Runtime/uvrtdb/.runtime.* ] && cp -rf $from/DB/Runtime/uvrtdb/.runtime.* $to/DB/Runtime/uvrtdb/
    [ -e $from/DB/Runtime/uvrtdb/uvrtdb.hash ] && cp -f $from/DB/Runtime/uvrtdb/uvrtdb.hash $to/DB/Runtime/uvrtdb/
    [ -e $from/DB/Runtime/uvrtdb/mem.* ] && cp -f $from/DB/Runtime/uvrtdb/mem.* $to/DB/Runtime/uvrtdb/
    [ -e $from/DB/Runtime/nocoord.rtdb ] && cp -rf $from/DB/Runtime/nocoord.rtdb $to/DB/Runtime/
    [ -e $from/DB/Runtime/waveconvdb.dat ] && cp -rf $from/DB/Runtime/waveconvdb.dat $to/DB/Runtime/
    [ -e $from/DB/Runtime/.waveconvdb.dat.dir ] && cp -rf $from/DB/Runtime/.waveconvdb.dat.dir $to/DB/Runtime/
    [ -e $from/DB/Runtime/.waveconvdb.dat.config ] && cp -f $from/DB/Runtime/.waveconvdb.dat.config $to/DB/Runtime/
    [ -e $from/Synthesis/Hw_mem/Script/runtime_init.tcl ] && cp -rf $from/Synthesis/Hw_mem/Script/runtime_init.tcl $to/Synthesis/Hw_mem/Script/
    [ -e $from/Synthesis/Hw_mem/Init ] && cp -rf $from/Synthesis/Hw_mem/Init $to/Synthesis/Hw_mem/
    if [ $readback ] || [ $debug_db ] ; then
        [ -e $from/DB/Names ] && cp -rf $from/DB/Names $to/DB/
    fi
	if [ $debug_db ] ; then
        echo "Debug information is included!"
        [ -e $from/Uvd ] && cp -rf $from/Uvd $to/
        [ -e $from/DB/Runtime/uvrtdb/debug.* ] && cp -rf $from/DB/Runtime/uvrtdb/debug.* $to/DB/Runtime/uvrtdb/
        [ -e $from/DB/Runtime/uvrtdb/fv ] && cp -rf $from/DB/Runtime/uvrtdb/fv $to/DB/Runtime/uvrtdb/
        [ -e $from/DB/Runtime/uvrtdb/rr ] && cp -rf $from/DB/Runtime/uvrtdb/rr $to/DB/Runtime/uvrtdb/
        [ -e $from/DB/Runtime/uvrtdb/ffvd ] && cp -rf $from/DB/Runtime/uvrtdb/ffvd $to/DB/Runtime/uvrtdb/
        [ -e $from/DB/Runtime/glsgraph ] && cp -f $from/DB/Runtime/glsgraph $to/DB/Runtime/
        [ -e $from/DB/Runtime/glsgraphgz ] && cp -f $from/DB/Runtime/glsgraphgz $to/DB/Runtime/
        [ -e $from/DB/Runtime/.glsgraphgz.dir ] && cp -rf $from/DB/Runtime/.glsgraphgz.dir $to/DB/Runtime/
        [ -e $from/DB/Runtime/.glsgraphgz.config ] && cp -f $from/DB/Runtime/.glsgraphgz.config $to/DB/Runtime/
	fi
    if [ $readback ] ; then
        echo "Readback information is included!"
        [ -e $from/DB/Runtime/uvrtdb/rtl2gate.* ] && cp -rf $from/DB/Runtime/uvrtdb/rtl2gate.* $to/DB/Runtime/uvrtdb/
        [ -e $from/DB/Runtime/uvrtdb/signal ] && cp -rf $from/DB/Runtime/uvrtdb/signal $to/DB/Runtime/uvrtdb/
        [ -e $from/DB/Runtime/uvrtdb/coord ] && cp -rf $from/DB/Runtime/uvrtdb/coord $to/DB/Runtime/uvrtdb/
        [ -e $from/DB/Runtime/uvrtdb/rb ] && cp -rf $from/DB/Runtime/uvrtdb/rb $to/DB/Runtime/uvrtdb/
    fi
fi



for ((i=0; i<=100; i++))
do
for ((j=0; j<=5; j++))
do
  prPath="Compile/PnR/B$i/F$j"
  binFile="MOD_b${i}_f$j.bin"
  xmlFile="B${i}F$j.xml"
  if [ -e "$from/$prPath/$binFile" ] ; then
	target_file=$(readlink "$from/$prPath/$binFile")
	target_dir=$(dirname "$target_file")
	mkdir -p $to/$prPath/$target_dir
	cp -f $from/$prPath/$target_file $to/$prPath/$target_dir/
	cp -P $from/$prPath/$binFile $to/$prPath/
	if [ -e $from/$prPath/$xmlFile ] ; then
		cp -f $from/$prPath/$xmlFile $to/$prPath/
	fi
  fi
done
done

is_failed=0
cd $to
toFiles=$(find . -type f)
cd -
for i in $toFiles
do
  if [ -s $from/$i ]; then
	#echo Checking $i ...
	chksum1=$(md5sum $to/$i | awk '{print $1}')
	chksum2=$(md5sum $from/$i | awk '{print $1}')
	if [ "$chksum1" != "$chksum2" ]; then
		echo "Error: $to/$i $chksum1 is not same with $from/$i $chksum2"
		is_failed=1
	fi
  fi
done

if [ $is_failed -eq 1 ] ; then
	echo "Checksum NOT PASS"
	exit 1
else
	echo "Checksum PASS"
	exit 0
fi
