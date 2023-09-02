FROM alpine:3.18

RUN echo -e "https://mirror.tuna.tsinghua.edu.cn/alpine/v3.18/main/\nhttps://mirror.tuna.tsinghua.edu.cn/alpine/v3.18/community/" > /etc/apk/repositories && \
    apk add --no-cache bash python3 py3-pip nginx nginx-mod-http-vod nginx-mod-rtmp ffmpeg

# 暂不使用
# RUN apk add --no-cache ffmpeg

# 调试工具
# RUN apk add --no-cache vim curl

ADD ./launcher /opt/launcher
RUN chmod +x /opt/launcher/launch.sh
RUN pip install -r /opt/launcher/requirements.txt --no-cache-dir --index-url https://pypi.tuna.tsinghua.edu.cn/simple/

ENV HV_RELEASE=true
ENV HV_NGINX_WORKER=auto
ENV HV_LIVE_ENABLE=true
ENV HV_LIVE_RTMP_PORT=1935
ENV HV_LIVE_HTTP_PORT=8801
ENV HV_LIVE_HLS_FRAGMENT=10s
ENV HV_LIVE_HLS_PLAYLIST_LENGTH=40s
ENV HV_LIVE_DASH_FRAGMENT=2s
ENV HV_LIVE_DASH_PLAYLIST_LENGTH=30s
# 不要开启，会导致 rtsp 拉流失败
ENV HV_LIVE_MULTI_WORKER=false
ENV HV_LIVE_STAT=true
ENV HV_VOD_ENABLE=true
ENV HV_VOD_HTTP_PORT=8802
ENV HV_VOD_STAT=true

EXPOSE 1935
EXPOSE 8801
EXPOSE 8802
VOLUME [ "/vod-res" ]

ENTRYPOINT [ "/opt/launcher/launch.sh" ]
