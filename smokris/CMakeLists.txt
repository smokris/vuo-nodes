cmake_minimum_required(VERSION 3.2)
project(smokris-vuo-nodes)

set(CMAKE_FRAMEWORK_PATH "${PROJECT_BINARY_DIR}/../../Vuo Editor.app/Contents/Frameworks")
find_library(VUO_FRAMEWORK Vuo)

set(userModules "~/Library/Application\ Support/Vuo/Modules")
file(MAKE_DIRECTORY ${userModules})

set(genericNodes
	smokris.osc.message.get.list.c
)
set(nodes
	smokris.make.glitch.image.c
	smokris.make.glitch.points.c
	smokris.object.reinterpret.c
	smokris.macam.receive.m
	smokris.snapshot.c
)

foreach (node ${genericNodes} ${nodes})
	set(compiledNode ${PROJECT_BINARY_DIR}/${node})
	string(REGEX REPLACE "\\.[cm]$" ".vuonode" compiledNode "${compiledNode}")
	add_custom_command(
		COMMAND ${VUO_FRAMEWORK}/Helpers/vuo-compile
			${PROJECT_SOURCE_DIR}/${node}
			--header-search-path ${PROJECT_SOURCE_DIR}/../macam64-0.1.0/driver_core
			--header-search-path ${PROJECT_SOURCE_DIR}/../macam64-0.1.0/cameras
			--header-search-path ${PROJECT_SOURCE_DIR}/../macam64-0.1.0/utilities
			--output ${compiledNode}
		OUTPUT ${compiledNode}
	)
	list(APPEND compiledNodes ${compiledNode})
endforeach()

set(nodeSet ${PROJECT_BINARY_DIR}/smokris.vuonode)
add_custom_command(
	DEPENDS ${genericNodes} ${compiledNodes}
	COMMAND zip --junk-paths ${PROJECT_BINARY_DIR}/smokris.zip ${compiledNodes}
		&& (cd ${PROJECT_SOURCE_DIR} && zip ${PROJECT_BINARY_DIR}/smokris.zip ${genericNodes})
		&& mv ${PROJECT_BINARY_DIR}/smokris.zip ${nodeSet}
		&& cp ${nodeSet} ${userModules}
	OUTPUT ${nodeSet}
)
add_custom_target(nodeSet ALL DEPENDS ${nodeSet})
