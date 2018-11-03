FROM perl:5.26.2-slim

ENV PERL_MM_USE_DEFAULT=1 PERL_CARTON_PATH=/carton

RUN apt-get update \
 && apt-get install -y libgmp-dev rsync libssl-dev ca-certificates gcc zlib1g-dev \
 && cpanm -n Mozilla::CA IO::Socket::SSL App::cpm \
 && cpm install -g Carton \
 && rm -fr /root/.cpanm /root/.perl-cpm /var/cache/apt/lists/* /tmp/*

COPY cpanfile cpanfile.snapshot /metacpan-api/
WORKDIR /metacpan-api

RUN useradd -m metacpan-api -g users \
 && mkdir /carton /CPAN \
 && apt-get update \
 && apt-get install -y libxml2-dev libexpat1-dev libpq-dev \
 && cpm install -L /carton \
 && rm -fr /root/.cpanm /root/.perl-cpm /var/cache/apt/lists/* /tmp/*

RUN chown -R metacpan-api:users /metacpan-api /carton /CPAN

VOLUME /carton

VOLUME /CPAN

USER metacpan-api:users

EXPOSE 5000

CMD ["carton", "exec", "plackup", "-p", "5000", "-r"]
