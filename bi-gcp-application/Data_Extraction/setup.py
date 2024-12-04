import setuptools


# Setup File to find & include all the custom dependencies

setuptools.setup(
    name='Custom packages',
    version='1.0.0',
    install_requires=[],
    packages=setuptools.find_packages()
)