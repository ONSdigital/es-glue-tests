# SPP - ES Results Glue Tests

This project contains the terraform, python test_step and python dependency module code used in the recent investigative spike into AWS Glue as a serverless function execution platform vs AWS Lambda.

### Usage

### Terraform

Brings up test python shell AWS glue job which enumerates installed library versions installed in python shell execution context.


### pipeline_deps

Python module which can be built to install library dependencies into a python shell job.

Basic steps are to install wheel, update setup.py with your needed dependencies then use `python setup.py bdist_wheel` to build the wheel.

