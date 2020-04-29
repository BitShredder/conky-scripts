#!/bin/sh

sleep 5

conky -q -c ~/.conky/OSBadge/conkyrc &
conky -q -c ~/.conky/Calendar/conkyrc &
conky -q -c ~/.conky/BCDClock/conkyrc &
exit
