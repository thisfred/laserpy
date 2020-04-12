include Makefile.venv

Makefile.venv:
	curl \
		-o Makefile.fetched \
		-L "https://github.com/sio/Makefile.venv/raw/v2020.02.26/Makefile.venv"
	echo "e0aeebe87c811fd9dfd892d4debb813262646e3e82691e8c4c214197c4ab6fac *Makefile.fetched" \
		| sha256sum --check - \
		&& mv Makefile.fetched Makefile.venv

PY=python3.8

.PHONY: test

test: venv
	tox

.PHONY: test_extras
test_extras: venv
	pip install -e .[test]

.PHONY: dev_extras
dev_extras: venv
	pip install -e .[dev]

.PHONY: test_continually
test_continually: test_extras
	ptw -- --testmon

.PHONY: precommit_update
precommit_update: dev_extras
	pre-commit autoupdate

.PHONY: test_release
test_release: dev_extras distclean
	python setup.py sdist bdist_wheel 
	twine upload --repository-url https://test.pypi.org/legacy/ dist/*

.PHONY: release
release: dev_extras distclean
	python setup.py sdist bdist_wheel
	twine upload dist/*

.PHONY: distclean
distclean:
	rm -rf dist build
