/**
 * @file
 * smokris.snapshot node implementation.
 *
 * @copyright Copyright © 2015 Steve Mokris.
 * This code may be modified and distributed under the terms of the MIT License.
 */

#include "node.h"

VuoModuleMetadata({
					 "title" : "Manage Snapshots",
					 "description" : "When `Take Snapshot` receives an event, this node stores the values of its inputs. \
									  When `Recall Snapshot` receives an event, this node updates its output ports with the stored snapshot values.",
					 "version" : "1.0.0",
				 });

struct snapshot
{
	VuoColor color;
	VuoPoint2d position;
};

struct nodeInstanceData
{
	struct snapshot snapshots[16];
};

struct nodeInstanceData *nodeInstanceInit(void)
{
	struct nodeInstanceData *context = (struct nodeInstanceData *)calloc(1, sizeof(struct nodeInstanceData));
	VuoRegister(context, free);
	return context;
}

void nodeInstanceEvent
(
	VuoInstanceData(struct nodeInstanceData *) context,

	VuoInputData(VuoInteger, {"default":1, "suggestedMin":1, "suggestedMax":16}) takeSnapshot,
	VuoInputEvent({"data":"takeSnapshot","hasPortAction":true}) takeSnapshotEvent,

	VuoInputData(VuoInteger, {"default":1, "suggestedMin":1, "suggestedMax":16}) recallSnapshot,
	VuoInputEvent({"data":"recallSnapshot","hasPortAction":true}) recallSnapshotEvent,

	VuoInputData(VuoColor) color,
	VuoInputData(VuoPoint2d) position,

	VuoOutputData(VuoColor) recalledColor,
	VuoOutputData(VuoPoint2d) recalledPosition
)
{
	if (takeSnapshotEvent)
	{
		VuoInteger index = MIN(MAX(takeSnapshot,1),16) - 1;
		(*context)->snapshots[index].color    = color;
		(*context)->snapshots[index].position = position;
	}

	if (recallSnapshotEvent)
	{
		VuoInteger index = MIN(MAX(recallSnapshot,1),16) - 1;
		*recalledColor    = (*context)->snapshots[index].color;
		*recalledPosition = (*context)->snapshots[index].position;
	}
}

void nodeInstanceFini(VuoInstanceData(struct nodeInstanceData *) context)
{
}
