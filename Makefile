EGG_NAME=clic
SHELL=/bin/bash -o pipefail

all: compile test lint

include ../conf.mk

bin/pip:
	python3 -m venv .

lib/.requirements: requirements.txt requirements-to-freeze.txt setup.py bin/pip
	# Install frozen requirements
	./bin/pip install -r requirements.txt
	# Make sure any new requirements are available
	./bin/pip install -r requirements-to-freeze.txt
	# Freeze the output at current state
	./bin/pip freeze | grep -v egg=$(EGG_NAME) > requirements.txt
	touch lib/.requirements

compile: lib/.requirements deploy/deploy.sh

test: compile
	./bin/pytest $(EGG_NAME) tests

lint: lib/.requirements
	./bin/flake8 --ignore=E501 $(EGG_NAME)/ tests/

coverage: compile
	./bin/coverage run ./bin/py.test tests/
	./bin/coverage html
	mkdir -p ../client/www/coverage
	ln -rs htmlcov ../client/www/coverage/server
	echo Visit http://...//coverage/server/index.html

start: lib/.requirements # test
	./bin/uwsgi \
	    --master \
	    --processes=1 --threads=1 \
	    --enable-threads --thunder-lock \
	    --honour-stdin \
	    --mount /=$(EGG_NAME).uwsgi:app \
	    --chmod-socket=666 \
	    -s $(API_SOCKET)

deploy/deploy.sh: $(PROJECT_PATH)/conf.mk deploy/generate.sh
	deploy/generate.sh

.PHONY: compile test lint coverage start
