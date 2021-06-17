# Compiler image
# -------------------------------------------------------------------------------------------------
FROM alpine:3.13.5 AS compiler

WORKDIR /root

RUN apk --no-cache add \
    bash \
    gcc \
    g++ \
    build-base \
    cmake \
    gmp-dev \
    libsodium-dev \
    libsodium-static \
    git

RUN git clone https://github.com/madMAx43v3r/chia-plotter.git \
&& cd chia-plotter \
&& git submodule update --init \
&& ./make_devel.sh \
&& ./build/chia_plot --help

# Runtime image
# -------------------------------------------------------------------------------------------------
FROM alpine:3.13.5 AS runtime

ENV final_dir="/plots"
ENV tmp_dir1="/tmp1"
ENV tmp_dir2="/tmp2"
ENV logs_dir="/logs"
ENV farmer_key="xxx"
ENV pool_key="xxx"
ENV threads=4
ENV space_per_plot=109836384768

WORKDIR /root

RUN apk --no-cache add \
    bash \
    gawk \
    coreutils \
    gmp-dev \
    libsodium-dev

COPY --from=compiler /root/chia-plotter/build /usr/lib/chia-plotter
RUN ln -s /usr/lib/chia-plotter/chia_plot /usr/bin/chia_plot

WORKDIR /usr/lib/chia-plotter
ADD ./plotfree.sh plotfree.sh 

ENTRYPOINT ["bash", "./plotfree.sh"]