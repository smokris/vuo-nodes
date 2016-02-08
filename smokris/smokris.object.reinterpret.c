/**
 * @file
 * smokris.object.reinterpret node implementation.
 *
 * @copyright Copyright © 2016 Steve Mokris.
 * This code may be modified and distributed under the terms of the MIT License.
 */

#include "node.h"
#include <OpenGL/CGLMacro.h>

VuoModuleMetadata({
					 "title" : "Reinterpret 3D Object",
					 "keywords" : [ "glitch" ],
					 "description" : "Changes a 3D object's element assembly method.\n\n\
Primitive Types:\n\n\
- 0 = Triangles\n\
- 1 = Triangle Strip\n\
- 2 = Triangle Fan\n\
- 3 = Lines\n\
- 4 = Line Strip\n\
- 5 = Points",
					 "version" : "1.0.0",
				 });

void nodeEvent
(
	VuoInputData(VuoSceneObject) object,
	VuoInputData(VuoInteger, {"default":0, "suggestedMin":0, "suggestedMax":5}) primitiveType,
	VuoInputData(VuoReal, {"default":0.01, "suggestedMin":0.0, "suggestedStep":0.001}) primitiveSize,
	VuoOutputData(VuoSceneObject) reinterpretedObject
)
{
	*reinterpretedObject = VuoSceneObject_copy(object);
	VuoSceneObject_apply(reinterpretedObject, ^(VuoSceneObject *currentObject, float modelviewMatrix[16])
	{
		if (!currentObject->mesh)
			return;

		for (unsigned int i = 0; i < currentObject->mesh->submeshCount; ++i)
		{
			currentObject->mesh->submeshes[i].elementAssemblyMethod = VuoInteger_clamp(primitiveType, 0, 5);
			currentObject->mesh->submeshes[i].primitiveSize = primitiveSize;
		}
	});
}
