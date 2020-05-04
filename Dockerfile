# Use the appropriate version.
FROM quay.io/aptible/mongodb:4.0

ADD run-arbiter.sh /usr/bin/run-arbiter.sh

ENTRYPOINT ["run-arbiter.sh"]
