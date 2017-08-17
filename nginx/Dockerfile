FROM nginx

RUN apt-get update && apt-get install -y autoconf g++ make openssl libssl-dev libcurl4-openssl-dev && \
      apt-get clean && \
      rm -rf /var/lib/apt/lists/*

COPY nginx.conf /etc/nginx/nginx.conf
