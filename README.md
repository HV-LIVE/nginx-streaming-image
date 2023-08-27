# 基于以下开源项目

- [nginx-rtmp-module](https://github.com/arut/nginx-rtmp-module)
- [nginx-vod-module](https://github.com/kaltura/nginx-vod-module)

# 功能

- RTMP 协议直播推流与播放
- HLS 协议直播
- DASH 协议直播
- HLS 协议点播（仅支持本地文件）
- DASH 协议点播（仅支持本地文件）

# 部署

- 端口映射

  - RTMP 端口: 用于 RTMP 协议推流与播放。容器端口为 `1935`
  - 直播 HTTP 端口: 用于 HLS/DASH 协议的直播。容器端口为 `8801`
  - 点播 HTTP 端口: 用于 HLS/DASH 协议的点播。容器端口为 `8802`

- 目录挂载

  - 点播资源目录: 用于存放点播的资源文件。容器目录为 `/vod-res`
  - 启动配置目录: 用于存放启动配置文件。容器目录为 `/etc/launcher`

- 高级配置

  - [配置列表](#配置列表)
  - 通过环境变量控制，启动容器时可以通过 `-e` 指定

- 部署命令

  ```bash
  docker run -d --restart=always --name nginx-streaming \
          -p 1935:1935 -p 8801:8801 -p 8802:8802 \
          -v {点播资源目录}:/vod-res \
          -v {启动配置目录}:/etc/launcher \
          hvlive/nginx-streaming:latest
  ```

# 直播

## RTMP 直播推流与播放

- 推流与播放地址

  - 完整地址为 `rtmp://{server-ip}:1935/live/{name}`，文档中用 `{rtmp_full_url}` 表示
  - 多个客户端同时推流时，`{name}` **不能重复**
  - 请留意 `{name}` 在后续使用 `HLS/DASH` 播放时也会用到

- OBS 推流配置

  - 服务器: `rtmp://{ip}:1935/live`
  - 串流密钥: `{name}`

- FFmpeg 推流命令

  ```bash
  # 推流本地视频文件
  ffmpeg -stream_loop -1 -re -i "{本地视频路径}" -c:v copy -c:a copy -f flv {rtmp_full_url}
  ```

- FFmpeg 播放命令

  ```bash
  ffplay -fflags nobuffer {rtmp_full_url}
  ```

- VLC 及其它播放器使用 `{rtmp_full_url}` 进行播放

## HLS 直播

- 播放地址
  - 完整地址为 `http://{server-ip}:8801/live-hls/{name}/index.m3u8`
  - `{name}` 同 [RTMP 直播推流与播放](#rtmp-直播推流与播放) 中的 `{name}`

## DASH 直播

- 播放地址
  - 完整地址为 `http://{server-ip}:8801/live-dash/{name}/index.mpd`
  - `{name}` 同 [RTMP 直播推流与播放](#rtmp-直播推流与播放) 中的 `{name}`

## 查看统计

- 统计地址为 `http://{server-ip}:8801/live-stat/`

## 使用 FFmpeg 转 DASH

- FFmpeg 版本: `6.0`

- 配置 FFmpeg 参数

  - 参考 [官方文档](https://ffmpeg.org/ffmpeg-all.html#dash-2)
  - 编辑 `{启动配置目录}/config.ini` 文件
  - 添加或修改如下内容（**重启容器后生效**）

    ```ini
    [ENV_LIST]
    FFMPEG_DASH_OPTS =
        # 001
        -c copy
        # 002
        -c copy -window_size 10 -use_template 0 -use_timeline 0
        # 003
        -c copy -window_size 10 -use_template 1 -use_timeline 1
        # 004 无法播放
        -c copy -window_size 10 -use_template 1 -use_timeline 0
        # 005
        -c copy -window_size 10 -use_template 0 -use_timeline 1
    ```

- 播放地址
  - 完整地址为 `http://{server-ip}:8801/live-ffmpeg-dash/{name}/{index}/manifest.mpd`
  - `{name}` 同 [RTMP 直播推流与播放](#rtmp-直播推流与播放) 中的 `{name}`
  - `{index}` 对应 `FFMPEG_DASH_OPTS` 中的位置，从 `1` 开始，不满 `3位数` 前边补`0`

# 点播

## 准备资源

- 将点播使用的音视频资源放入 `{点播资源目录}`
- 记录下音视频文件在 `{点播资源目录}` 中的相对路径，文档中用 `{vod_res_path}` 表示
- 例如 `{点播资源目录}` 为 `/mydir1/mydir2`，音视频文件路径为 `/mydir1/mydir2/test1/test2/test3.mp4`，则相对路径为 `test1/test2/test3.mp4`

## HLS 点播

- 播放地址
  - 完整地址为 `http://{server-ip}:8802/vod-hls/{vod_res_path}/index.m3u8`

## DASH 点播

- 播放地址
  - 完整地址为 `http://{server-ip}:8802/vod-dash/{vod_res_path}/manifest.mpd`
  - **注意结尾是 `manifest.mpd`**

## 查看统计

- 统计地址为 `http://{server-ip}:8802/vod-stat/`

# 配置列表

| 环境变量                     | 默认值 | 说明                 |
| ---------------------------- | ------ | -------------------- |
| HV_LIVE_ENABLE               | true   | 是否开启直播功能     |
| HV_LIVE_RTMP_PORT            | 1935   | 直播 RTMP 端口       |
| HV_LIVE_HTTP_PORT            | 8801   | 直播 HTTP 端口       |
| HV_LIVE_HLS_FRAGMENT         | 2s     | HLS 分片的长度       |
| HV_LIVE_HLS_PLAYLIST_LENGTH  | 10s    | HLS 播放列表的长度   |
| HV_LIVE_DASH_FRAGMENT        | 2s     | DASH 分片的长度      |
| HV_LIVE_DASH_PLAYLIST_LENGTH | 10s    | DASH 播放列表的长度  |
| HV_LIVE_STAT                 | true   | 是否开启直播统计功能 |
| HV_VOD_ENABLE                | true   | 是否开启点播功能     |
| HV_VOD_HTTP_PORT             | 8802   | 点播 HTTP 端口       |
| HV_VOD_STAT                  | true   | 是否开启点播统计功能 |

# 功能缺陷

## `Nginx` 开启多个 `Worker` 进程会导致无法使用 RTMP 协议播放

- 虽然 `nginx-rtmp-module` 提供了 `rtmp_auto_push` 等配置项，但实际依然无法正常工作
- 怀疑可能是 Nginx 版本太高的问题

## 直播延迟在 30 ~ 90 秒左右

- 参考网上配置了 `hls_fragment` 和 `hls_playlist_length` 等配置项，但效果不明显
- 怀疑可能是缺少关键帧，[类似问题](https://github.com/arut/nginx-rtmp-module/issues/1026#issuecomment-302059909)

## 点播不支持 `MPEG-TS` 格式

- [参考问题](https://github.com/kaltura/nginx-vod-module/issues/1036)

## 暂不支持 `HTTPS`
