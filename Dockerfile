FROM hugomods/hugo:reg-ci AS hugo
COPY . /src
WORKDIR /src
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENV HUGO_BASE_URL=https://carsoncall-dev.fly.dev
ENV APPEND_PORT=false
CMD ["/entrypoint.sh"]

EXPOSE 1313
