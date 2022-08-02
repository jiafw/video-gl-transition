# video-transition
一个直接使用docker配置gl-transition的方法，参考https://github.com/transitive-bullshit/ffmpeg-gl-transition ，由于此项目中的dockerfile直接使用git下载，但是其diff文件又不与最新的版本适配，所以无法直接配置成功。


使用docker，可降低配置难度

```bash
docker image build -t docker-ffmpeg:v1 .
docker run -i -t docker-ffmpeg:v1 /bin/bash
```

也增加了最新的转场效果，增加到84个，但是实测时有的效果无法成功，成功的只有60个左右，可能是因为ffmpeg版本较老的缘故，如果用最新版本，gl-transition又无法直接通过dockerfile配置成功


让你在pc平台将多个视频合成为一个且在视频与视频之间添加酷炫的转场

注意事项：目前只支持同尺寸的视频合成
