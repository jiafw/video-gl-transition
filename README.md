# video-transition
让你在pc平台将多个视频合成为一个且在视频与视频之间添加酷炫的转场
注意事项：目前只支持同尺寸的视频合成

由于配置gl-transitions不太容易，因此添加了dockerfile，可以使用docker，降低配置难度
'''
docker image build -t docker-ffmpeg:v1 .
docker run -i -t docker-ffmpeg:v1 /bin/bash
'''

也增加了最新的转场效果，增加到84个，但是实测时有的效果无法成功


