FROM hugomods/hugo:reg-ci AS hugo
COPY . /src
WORKDIR /src
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
CMD ["/entrypoint.sh"]

EXPOSE 1313
