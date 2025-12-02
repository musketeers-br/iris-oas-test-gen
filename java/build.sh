case "${PWD}" in
  */java)
    ;; # All good, continue
  *)
    echo "Error: This script should be run from the 'java' directory."
    echo "You are currently in: ${PWD}"
    exit 1
    ;;
esac

docker run --rm \
  -v ${PWD}:/usr/src/app \
  -v ${HOME}/.m2:/root/.m2 \
  -w /usr/src/app \
  maven:3.9-eclipse-temurin-11 \
  mvn clean package

   #now, if the docker command is successfull, exectue the command cp target/iris-object-script-openapi-generator-1.0.0.jar dist/

  cp target/iris-object-script-openapi-generator-1.0.0.jar dist/