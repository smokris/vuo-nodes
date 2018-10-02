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

VUO_FRAMEWORK_PATH = "../Vuo Editor.app/Contents/Frameworks/Vuo.framework/Helpers"

genericNode.input = GENERIC_NODE_SOURCES
genericNode.output = ${QMAKE_FILE_IN_BASE}.vuonode
genericNode.commands = '"$$VUO_FRAMEWORK_PATH/vuo-compile"' --output ${QMAKE_FILE_OUT} ${QMAKE_FILE_IN} \
	&& zip ${QMAKE_FILE_OUT}.zip ${QMAKE_FILE_OUT} ${QMAKE_FILE_IN} \
	&& mv ${QMAKE_FILE_OUT}.zip ${QMAKE_FILE_OUT}
QMAKE_EXTRA_COMPILERS += genericNode

node.input = NODE_SOURCES
node.output = ${QMAKE_FILE_IN_BASE}.vuonode
node.commands = '"$$VUO_FRAMEWORK_PATH/vuo-compile"' --output ${QMAKE_FILE_OUT} ${QMAKE_FILE_IN}
QMAKE_EXTRA_COMPILERS += node

QMAKE_CLEAN = *.vuonode
