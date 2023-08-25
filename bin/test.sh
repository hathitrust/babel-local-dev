#!/bin/bash
cd /htapps/babel/imgsrv
prove -lre 'perl -I lib -I vendor/common-lib/lib -I vendor/plack-lib/lib -I vendor/slip-lib/lib' t