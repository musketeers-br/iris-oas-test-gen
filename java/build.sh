docker run --rm \
  -v ${PWD}:/usr/src/app \
  -v ${HOME}/.m2:/root/.m2 \
  -w /usr/src/app \
  maven:3.9-eclipse-temurin-11 \
  mvn clean package