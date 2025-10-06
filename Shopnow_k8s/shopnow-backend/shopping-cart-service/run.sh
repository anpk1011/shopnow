#!/bin/sh
set -e

# JVM mặc định (bạn có thể override bằng ENV JAVA_OPTS)
JAVA_OPTS="${JAVA_OPTS:- -Xms256m -Xmx512m}"

# Nếu có URL server Seeker thì tải và gắn agent
if [ -n "${SEEKER_SERVER_URL}" ]; then
  echo "[Seeker] Downloading agent from ${SEEKER_SERVER_URL} ..."
  # -k: bỏ kiểm tra cert trong lab; production nên import CA đúng thay vì -k
  curl -fsSLk -o /tmp/seeker-agent.zip \
    "${SEEKER_SERVER_URL}/rest/api/latest/installers/agents/binaries/JAVA"
  unzip -oq /tmp/seeker-agent.zip -d /tmp/seeker

  # Ghép -javaagent
  JAVA_OPTS="-javaagent:/tmp/seeker/seeker-agent.jar ${JAVA_OPTS}"

  # Truyền thêm tham số Seeker qua system properties (tùy chọn nhưng nên có)
  # Các biến nào không đặt sẽ được bỏ qua
  [ -n "${SEEKER_PROJECT_KEY}" ] && JAVA_OPTS="-Dseeker.project.key=${SEEKER_PROJECT_KEY} ${JAVA_OPTS}"
  [ -n "${SEEKER_APP_NAME}" ]    && JAVA_OPTS="-Dseeker.app.name=${SEEKER_APP_NAME} ${JAVA_OPTS}"
  [ -n "${SEEKER_ENV}" ]         && JAVA_OPTS="-Dseeker.env.name=${SEEKER_ENV} ${JAVA_OPTS}"
  [ -n "${SEEKER_SERVER_URL}" ]  && JAVA_OPTS="-Dseeker.server.url=${SEEKER_SERVER_URL} ${JAVA_OPTS}"
fi

echo "[App] Starting with JAVA_OPTS: ${JAVA_OPTS}"
exec java ${JAVA_OPTS} -jar /app/cart-service.war \
  --spring.config.location=/app/src/main/resources/application.properties
