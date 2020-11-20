# shadowsocks-libev

# Build
## Native
```
$ ./build_shadowsocks-libev.sh
```

## Cross-Compile
```
$ host=arm-linux-gnueabihf ./build_shadowsocks-libev.sh
```

# Install
```
$ scp ./out/shadowsocks-libev/bin/ss-server root@rpi1.local:/usr/bin/
$ scp ./out/simple-obfs/bin/obfs-server root@rpi1.local:/usr/local/bin/
```

# Run
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
