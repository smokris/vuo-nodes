/**
 * @file
 * smokris.make.glitch.points node implementation.
 *
 * @copyright Copyright © 2016 Steve Mokris.
 * This code may be modified and distributed under the terms of the MIT License.
 */

#include "node.h"
#include <OpenGL/CGLMacro.h>

VuoModuleMetadata({
					 "title" : "Make Glitchy Points",
					 "description" : "Outputs a list of points containing whatever data is sitting around in CPU RAM.",
					 "version" : "1.0.0",
				 });

void nodeEvent
(
	VuoInputData(VuoInteger, {"default":128, "suggestedMin":1, "suggestedStep":32}) pointCount,
	VuoOutputData(VuoList_VuoPoint3d) points
)
{
	// Allocate a list containing points with value (0,0,0).
	*points = VuoListCreateWithCount_VuoPoint3d(pointCount, (VuoPoint3d){0,0,0});

	// Replace its data with uninitialized CPU RAM.
	VuoPoint3d *pointData = VuoListGetData_VuoPoint3d(*points);
	size_t length = sizeof(VuoPoint3d) * abs(pointCount);
	void *garbage = malloc(length);
	memcpy(pointData, garbage, length);
	free(garbage);
}
