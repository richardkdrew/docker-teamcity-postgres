# DOCKER-VERSION 1.6.2
#
# TeamCity Build Server (Configured fro PostgreSQL) Dockerfile
#
# https://github.com/richardkdrew/docker-teamcity-postgres
#

FROM richardkdrew/teamcity

MAINTAINER Richard Drew <richardkdrew@gmail.com>

COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/opt/lib/teamcity/bin/teamcity-server.sh", "run"]