TEMPLATE = aux
cache()

GENERIC_NODE_SOURCES += \
	smokris.osc.message.get.list.c

NODE_SOURCES += \
	smokris.make.glitch.image.c \
	smokris.make.glitch.points.c \
	smokris.object.reinterpret.c \
	smokris.snapshot.c

OTHER_FILES += $$GENERIC_NODE_SOURCES $$NODE_SOURCES

VUO_FRAMEWORK_PATH = ../../framework
VUO_USER_MODULES_PATH = ~/Library/Application\ Support/Vuo/Modules

genericNode.input = GENERIC_NODE_SOURCES
genericNode.output = ${QMAKE_FILE_IN_BASE}.vuonode
genericNode.commands = $${VUO_FRAMEWORK_PATH}/vuo-compile --output ${QMAKE_FILE_OUT} ${QMAKE_FILE_IN} \
	&& mkdir -p "$${VUO_USER_MODULES_PATH}" \
	&& zip ${QMAKE_FILE_OUT}.zip ${QMAKE_FILE_OUT} ${QMAKE_FILE_IN} \
	&& cp ${QMAKE_FILE_OUT}.zip "$${VUO_USER_MODULES_PATH}/${QMAKE_FILE_OUT}"
QMAKE_EXTRA_COMPILERS += genericNode

node.input = NODE_SOURCES
node.output = ${QMAKE_FILE_IN_BASE}.vuonode
node.commands = $${VUO_FRAMEWORK_PATH}/vuo-compile --output ${QMAKE_FILE_OUT} ${QMAKE_FILE_IN} \
	&& mkdir -p "$${VUO_USER_MODULES_PATH}" \
	&& cp ${QMAKE_FILE_OUT} "$${VUO_USER_MODULES_PATH}"
QMAKE_EXTRA_COMPILERS += node

QMAKE_CLEAN = *.vuonode
