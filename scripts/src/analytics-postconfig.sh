#!/bin/bash
# Kyle McCormick

# Copy and modify config if we haven't already.
cd /edx/app/analytics_pipeline/analytics_pipeline
if [ ! -f override.cfg ]; then
	cat config/luigi_docker.cfg | sed -e "s/engine = hadoop/engine = local/g" > override.cfg
fi

# Get the necessary Vertica driver.
cd /edx/app/hadoop/sqoop/lib
if [ ! -f vertica-jdbc-9.1.1-0.jar ]; then
	sudo apt-get install wget -y
	wget https://vertica.com/client_drivers/9.1.x/9.1.1-0/vertica-jdbc-9.1.1-0.jar
fi

# Fix permission issue that Kyle was having that was preventing
# edx.analytics.tasks from getting installed correctly.
# If you don't have this problem, this block should get skipped.
cd /edx/app/analytics_pipeline
if [ ! -f venvs/analytics_pipeline/bin/launch-task ]; then
	sudo chown hadoop -R analytics_pipeline
	cd analytics_pipeline
	make develop-local
	cd ..
fi
cd analytics_pipeline

alias build-learner-report="launch-task BuildLearnerProgramReport --local-scheduler --vertica-credentials /edx/app/analytics_pipeline/analytics_pipeline/production-credentials.json --output-root='hdfs://namenode:8020/output' --enrollments-table kdmccormick_scratch_table"

echo 'all set.'
