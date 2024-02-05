FROM gcr.io/google.com/cloudsdktool/google-cloud-cli:462.0.1-emulators

RUN apt-get update \
    && apt-get install --yes tini \
    && rm -rf /var/lib/apt/lists/*

ADD start.sh /start.sh

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/start.sh"]
