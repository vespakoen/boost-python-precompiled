from setuptools import setup, find_packages

setup(
    name = 'dummy',
    version='1.0',
    packages=find_packages(),
    has_ext_modules=lambda : True # fool pip that we are a native module so cibuildhweel doesn't complain
)
