# shadowsocks-libev

## Build
### Native
```
$ ./build_shadowsocks-libev.sh
```

### Cross-Compile
```
$ host=arm-linux-gnueabihf ./build_shadowsocks-libev.sh
```

## Install
```
$ scp ./out/shadowsocks-libev/bin/ss-server root@rpi1.local:/usr/bin/
$ scp ./out/simple-obfs/bin/obfs-server root@rpi1.local:/usr/local/bin/
$ scp ./config.json root@rpi1.local:/etc/shadowsocks-libev/
$ scp ./ss-server.service root@rpi1.local:/etc/systemd/system/
```

## Run
```
$ systemctl start ss-server
$ systemctl status ss-server
$ systemctl stop ss-server
$ systemctl enable ss-server
```
```
$ ss-server \
       -s 0.0.0.0 \
       -s :: \
       -p 8388 \
       -k password \
       -m chacha20-ietf-poly1305 \
       -t 300 \
       --fast-open \
       -d 8.8.8.8,8.8.4.4 \
       -u \
       --plugin obfs-server \
       --plugin-opts "obfs=tls;fast-open"
```

## Release
```
$ tar zcvf shadowsocks-libev-arm32v6hf.tar.gz ./out/shadowsocks-libev ./out/simple-obfs
```
