cmake_minimum_required(VERSION 3.16)

project(zone-clock)


set(QT_MIN_VERSION "6.5")
set(KF6_MIN_VERSION "6.0")


find_package(ECM ${KF6_MIN_VERSION} REQUIRED NO_MODULE)

set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})


include(KDEInstallDirs)
include(KDECMakeSettings)


find_package(KF6Package REQUIRED)


kpackage_install_package(
    .
    zone-clock
)