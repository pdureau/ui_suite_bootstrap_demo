.PHONY: clean install update upgrade check dist run export_content reimport_content

clean:
	- chmod 777 web/sites/default/files/
	- rm -rf web/sites/default/files/*
	- rm -rf web/sites/default/files/.*
	- cp .env.example .env

install:
	mkdir -p web/sites/default/files/
	cp -r web/modules/custom/ui_suite_bootstrap_demo_examples/assets/* web/sites/default/files/
	composer install
	# Because ui_patterns_bootstrap/bootstrap library
	- mkdir -p web/libraries
	- ln -s ../../vendor/twbs/bootstrap/dist web/libraries/bootstrap
	vendor/bin/drush si -v minimal --existing-config -y
	vendor/bin/drush upwd admin admin
	vendor/bin/drupal site:mode dev 
	vendor/bin/drush cron
	vendor/bin/drush cim -y
	vendor/bin/drush cr

update:
	git pull origin master
	composer install
	- ln -s ../../vendor/twbs/bootstrap/dist web/libraries/bootstrap
	vendor/bin/drush cim -y
	vendor/bin/drush cr

upgrade:
	composer update
	vendor/bin/drush updb
	vendor/bin/drush cex -y

check:
	composer validate --no-check-all --strict
	- vendor/bin/security-checker security:check composer.lock
	- prettier --write web/modules/custom/*/*.yml
	- vendor/bin/phpcs --standard=Drupal web/modules/custom
	- vendor/bin/phpcs --standard=DrupalPractice web/modules/custom
	- vendor/bin/phpcs --standard=PHPCompatibility web/modules/custom
	- vendor/bin/phpmd web/modules/custom text naming
	- vendor/bin/phpmd web/modules/custom text codesize
	- vendor/bin/phpmd web/modules/custom text design
	- vendor/bin/phpmd web/modules/custom text unusedcode
	- vendor/bin/drupal-check -d web/modules/custom
	- vendor/bin/drupal-check -a web/modules/custom
	- vendor/bin/drush config:inspect --only-error
	- vendor/bin/phpcpd web/modules/custom/
	- vendor/bin/twig-lint lint web/modules/custom/

dist:
	git archive -o ui_suite_bootstrap_demo-$$(date --iso-8601=seconds).tgz master

run:
	vendor/bin/drush rs

export_content:
	vendor/bin/drush dcem ui_suite_bootstrap_demo_examples

reimport_content:
	vendor/bin/drush pm-uninstall ui_suite_bootstrap_demo_examples
	vendor/bin/drush en ui_suite_bootstrap_demo_examples

