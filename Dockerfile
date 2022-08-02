# This is a contributed example of how to build ffmpeg-gl-transions using Docker
# If you use Docker, this should get the job done
# if you don't use Docker, you could still run the commands
# manually and get the same result


FROM debian:stretch
# should also work for
#FROM ubuntu:18.04

# everything is relative to /build
WORKDIR /build

# enable contrib/non-free
RUN sed -E -e 's/\s+main\s?$/ main contrib non-free /' /etc/apt/sources.list >/etc/apt/sources.list.new && mv /etc/apt/sources.list.new /etc/apt/sources.list

# update anything needed
RUN apt-get -y update -y && apt-get -y upgrade && apt-get -y install wget

# need git
RUN apt-get -y install git

# get ffmpeg sources
# RUN git clone http://source.ffmpeg.org/git/ffmpeg.git ffmpeg
RUN wget http://www.ffmpeg.org/releases/ffmpeg-4.2.2.tar.gz
RUN tar -zxvf ffmpeg-4.2.2.tar.gz && mv ffmpeg-4.2.2 ffmpeg
# get ffmpeg-gl-transition modifications
# this pulls from the original master for standalone use
# but you could modify to copy from your clone/repository
RUN git clone https://github.com/transitive-bullshit/ffmpeg-gl-transition.git

# dependencies needed for ffmpeg compile
RUN apt-get -y install gcc g++ make xorg-dev pkg-config \
                       libglew2.0 libglew-dev libglfw3-dev \
                       nasm yasm libx264-dev libx265-dev libvpx-dev libglu1-mesa-dev \
                       libmp3lame-dev libopus-dev libfdk-aac-dev

# disable EGL
RUN grep -v "define GL_TRANSITION_USING_EGL" /build/ffmpeg-gl-transition/vf_gltransition.c > ffmpeg/libavfilter/vf_gltransition.c
# if you want to try EGL comment the above line and uncomment the below line
# also replace -lglfw with -lEGL in the extra_libs section of the ffmpeg
# configure farther down this file
# NOTE: could not get EGL to work in container!
#RUN cp /build/ffmpeg-gl-transition/vf_gltransition.c ffmpeg/libavfilter/vf_gltransition.c

# apply patch
RUN (cd ffmpeg; git apply /build/ffmpeg-gl-transition/ffmpeg.diff)

# there are a bunch more libraries that you could possibly enable in ffmpeg
# to do see see configure --help of ffmpeg   add the flag below and any necessary library install above

# configure/compile/install ffmpeg
RUN (cd ffmpeg; ./configure --enable-libx264 --enable-libx265 --enable-libvpx  --enable-libfdk-aac --enable-libmp3lame --enable-libopus --enable-nonfree --enable-gpl --enable-opengl --enable-filter=gltransition --extra-libs='-lGLEW -lglfw -ldl' )
# the -j speeds up compilation, but if your container host is limited on resources, you may need to
# remove it to force a non-parallel build to avoid memory usage issues
RUN (cd ffmpeg; make -j)
RUN (cd ffmpeg; make install)

# needed for running it
RUN apt-get -y install xvfb

# try the demo
RUN (cd ffmpeg-gl-transition; ln -s /usr/local/bin/ffmpeg .)
RUN (cd ffmpeg-gl-transition; xvfb-run -s '+iglx -screen 0 1920x1080x24' bash concat.sh )
# result would be in out.mp4 in that directory

# install python
RUN apt-get -y install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev curl libbz2-dev
RUN wget https://www.python.org/ftp/python/3.9.1/Python-3.9.1.tgz && tar -xf Python-3.9.1.tgz
RUN (cd Python-3.9.1; ./configure --enable-optimizations)
RUN (cd Python-3.9.1; make -j)
RUN (cd Python-3.9.1; make install)
RUN ln -s /usr/local/bin/python3.9 /usr/bin/python


# drop you into a shell to look around
# modify as needed for actual use
ENTRYPOINT /bin/bash
