mkdir -p /root/logs

if [ -d /root/logs ]; then
    if [ -e /root/logs/pcrs.bk ]; then
        rm /root/logs/pcrs.bk
    fi
    PCRSFILE=`find /sys/ -name 'pcrs'`
    if [ "${PCRSFILE}x" == 'x' ]; then
        # tpm 2.0 case
	tpm2_pcrlist -T device > /root/logs/pcrs.old
    else
        # tpm 1.2 case
        sed -n '1,17p' $PCRSFILE > /root/logs/pcrs.old
    fi
#    cat $PCRSFILE > /root/logs/pcrs.bk
fi

echo mem > /sys/power/state

sleep 5

if [ -d /mnt/logs ]; then
    txt-stat > /mnt/logs/log-`date +%Y%m%d%H%M%S`
fi

if [ -d /root/logs ]; then
    txt-stat > /root/logs/log-`date +%Y%m%d%H%M%S`
fi

if [ -d /root/logs ]; then
    if [ "${PCRSFILE}x" == 'x' ]; then
        # tpm 2.0 case
	tpm2_pcrlist -T device > /root/logs/pcrs.new
    else
        # tpm 1.2 case
        sed -n '1,17p' $PCRSFILE > /root/logs/pcrs.new
    fi
#    if diff /root/logs/pcrs.bk $PCRSFILE
    if diff /root/logs/pcrs.old /root/logs/pcrs.new
    then
        if [ -e /root/logs/txt.log ]; then
            rm /root/logs/txt.log
        fi
        txt-stat > /root/logs/txt.log
        if grep 'TXT measured launch: FALSE' /root/logs/txt.log
        then
            echo "Secure S3 failed - TXT measured launch failed"
        else
            echo "Secure S3 success"
        fi
    else
        echo "Secure S3 failed"
    fi
fi

