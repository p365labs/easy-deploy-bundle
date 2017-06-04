#/bin/bash

SOURCE = "./lib"
TARGET?=71
CHECK_PHP_SYNTAX?=NO

# By default docker environment is used to run commands. To run without the predefined environment, set RUN_ENV=" " either as parameter or as environment variable
ifndef RUN_ENV
	RUN_ENV = docker run --workdir="/easydeploy" -v $(shell pwd):/elastica ruflin/elastica-dev-base
endif

.PHONY: clean
clean:
	docker-compose down -v
	rm -r -f ./build
	rm -r -f ./vendor
	rm -r -f ./composer.lock

# Runs commands inside virtual environemnt. Example usage inside docker: make run RUN="make phpunit"
.PHONY: run
run:
	docker run -v $(shell pwd):/elastica ruflin/elastica $(RUN)


### Quality checks / development tools ###
.PHONY: code-browser
code-browser:
	${RUN_ENV} phpcb --log ./build/logs --source ${SOURCE} --output ./build/code-browser

# Copy paste detector
.PHONY: cpd
cpd:
	${RUN_ENV} phpcpd --log-pmd ./build/logs/pmd-cpd.xml ${SOURCE}

.PHONY: messdetector
messdetector:
	${RUN_ENV} phpmd ${SOURCE} text codesize,unusedcode,naming,design ./build/phpmd.xml

.PHONY: messdetector-ci
messdetector-ci:
	${RUN_ENV} phpmd ${SOURCE} xml codesize,unusedcode,naming,design --reportfile ./build/logs/pmd.xml

.PHONY: dependencies
dependencies:
	${RUN_ENV} pdepend --jdepend-xml=./build/logs/jdepend.xml \
		--jdepend-chart=./build/pdepend/dependencies.svg \
		--overview-pyramid=./build/pdepend/overview-pyramid.svg \
		${SOURCE}

.PHONY: phpunit
phpunit:
	EXIT_STATUS=0 ; \
	vendor/bin/phpunit -c phpunit.xml.dist tests/  || EXIT_STATUS=$$? ; \
#	vendor/bin/phpunit -c tests/ --coverage-clover build/coverage/functional-coverage.xml --group functional || EXIT_STATUS=$$? ; \
#	vendor/bin/phpunit -c tests/ --coverage-clover build/coverage/shutdown-coverage.xml --group shutdown || EXIT_STATUS=$$? ; \
	exit $$EXIT_STATUS

.PHONY: tests
tests:
	# Rebuild image to copy changes files to the image
	make easydeploy-image
	make start
	mkdir -p build
	#execute remote server

	#start remote server listening on port 22
	docker run -d --network=easydeploybundle_deploynet easydeploybundle_easydeploy_remote --name=deployer_server

	#do tests on local machines
	docker run --network=easydeploybundle_deploynet easydeploybundle_easydeploy_local make phpunit


# Makes it easy to run a single test file. Example to run IndexTest.php: make test TEST="IndexTest.php"
.PHONY: test
test:
	make easydeploy-image
	make start
	mkdir -p build
	docker-compose run easydeploybundle_easydeploy_remote phpunit -c test/ ${TEST}

.PHONY: doc
doc:
	${RUN_ENV} phpdoc run -d lib/ -t build/docs --template=/root/composer/vendor/phpdocumentor/phpdocumentor/data/templates/clean

# Uses the preconfigured standards in .php_cs
.PHONY: lint
lint:
	${RUN_ENV} php-cs-fixer fix .

.PHONY: loc
loc:
	${RUN_ENV} cloc --by-file --xml --exclude-dir=build -out=build/cloc.xml .

.PHONY: phploc
phploc:
	${RUN_ENV} phploc --log-csv ./build/logs/phploc.csv ${SOURCE}


# VIRTUAL ENVIRONMENT
.PHONY: build
build:
	docker-compose build

.PHONY: start
start:
	docker-compose up -d --build

.PHONY: stop
stop:
	docker-compose stop

.PHONY: destroy
destroy: clean
	docker-compose kill
	docker-compose rm

# Stops and removes all containers and removes all images
.PHONY: destroy-environment
destroy-environment:
	make remove-containers
	-docker rmi $(shell docker images -q)

.PHONY: remove-containers
remove-containers:
	-docker stop $(shell docker ps -a -q)
	-docker rm -v $(shell docker ps -a -q)

# Starts a shell inside the elastica image
.PHONY: shell
shell:
	docker run -v $(shell pwd):/elastica -ti ruflin/elastica /bin/bash

# Starts a shell inside the elastica image with the full environment running
.PHONY: env-shell
env-shell:
	docker-compose run elastica /bin/bash

## DOCKER IMAGES

.PHONY: easydeploy-image
easydeploy-image:
	docker build -t easydeploybundle_easydeploy_remote -f env/easydeploy/Docker${TARGET} env/easydeploy/

# Builds all image locally. This can be used to use local images if changes are made locally to the Dockerfiles
.PHONY: build-images
build-images:
	docker build -f env/easydeploy/Docker${TARGET} env/easydeploy/
	make easydeploy-image

# Removes all local images
.PHONY: clean-images
clean-images:
	-docker rmi easydeploybundle_easydeploy_local
	-docker rmi easydeploybundle_easydeploy_remote

