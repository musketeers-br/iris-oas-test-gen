case "${PWD}" in
  */java)
    ;; # All good, continue
  *)
    echo "Error: This script should be run from the 'java' directory."
    echo "You are currently in: ${PWD}"
    exit 1
    ;;
esac

sh build.sh && \

docker exec -it iris-oas-test-gen-iris-1 /bin/bash -c "cp -rf /home/irisowner/dev/java/dist/iris-object-script-openapi-generator-1.0.0.jar /usr/irissys/lib/iris-oas-test-gen/" && \

openapiFile="/home/irisowner/dev/assets/person-api.json" && \
outputDir="/home/irisowner/dev/tests" && \
# packageName="sample.personapi"
packageName="dc.musketeers.irisOasTestGenDemo.personApi.tests"
docker exec -it iris-oas-test-gen-iris-1 /usr/bin/iris session iris -U IRISAPP "##class(dc.musketeers.irisOasTestGen.Main).BuildAndDeploy(\"$openapiFile\",\"$outputDir\",\"$packageName\")"