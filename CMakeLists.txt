cmake_minimum_required( VERSION 3.13...99.99)

project( mulle-domain VERSION 1.6.1 LANGUAGES NONE)

#
# Primarily used for packaging on Linux
#
# Debian:
#
# ```
# mkdir package
# cd package
# cmake ..
# cpack -G DEB
# ```
#

execute_process( COMMAND ./mulle-domain version
                 WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
                 OUTPUT_VARIABLE MULLE_DOMAIN_VERSION
                 OUTPUT_STRIP_TRAILING_WHITESPACE)
message( STATUS "MULLE_DOMAIN_VERSION is ${MULLE_DOMAIN_VERSION} according to mulle-domain")


set( PROJECT_VERSION "${MULLE_DOMAIN_VERSION}")


set( SCRIPTS
mulle-domain
)


file( GLOB LIBRARY_SCRIPTS
   "src/*.sh"
)


file( GLOB SCM_PLUGIN_SCRIPTS
   "src/plugins/*.sh"
)


INSTALL( FILES ${SCRIPTS}
PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ
            GROUP_EXECUTE GROUP_READ
            WORLD_EXECUTE WORLD_READ
DESTINATION "bin")


#
# future: install into libexec/mulle-domain/${MULLE_DOMAIN_VERSION}
#         allows multiple versions to co-exist (does it really ?)
#
INSTALL( FILES ${LIBRARY_SCRIPTS}
PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ
            GROUP_EXECUTE GROUP_READ
            WORLD_EXECUTE WORLD_READ
DESTINATION "libexec/mulle-domain")

INSTALL( FILES ${SCM_PLUGIN_SCRIPTS}
PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ
            GROUP_EXECUTE GROUP_READ
            WORLD_EXECUTE WORLD_READ
DESTINATION "libexec/mulle-domain/plugins")

######
#
# must be after CPACK_PACKAGE_VERSION
include( CMakePackage.cmake)
include( CPack)
