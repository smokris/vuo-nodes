/**
 * @file
 * smokris.osc.message.get.list node implementation.
 *
 * @copyright Copyright © 2018 Steve Mokris.
 * This code may be modified and distributed under the terms of the MIT License.
 */

#include "node.h"
#include "VuoOscMessage.h"

VuoModuleMetadata({
					 "title" : "Get Message Values (List)",
					 "keywords" : [ "address", "data" ],
					 "version" : "1.0.0",
					 "description" : "Outputs the OSC message’s address and a list containing its data values.  All OSC data values in the list must be of the same type (boolean, integer, real, or text).",
					 "genericTypes": {
						  "VuoGenericType1" : {
							  "defaultType" : "VuoReal",
							  "compatibleTypes": [ "VuoBoolean", "VuoInteger", "VuoReal", "VuoText" ]
						  }
					 },
				 });

void nodeEvent
(
		VuoInputData(VuoOscMessage) message,
		VuoOutputData(VuoText) address,
		VuoOutputData(VuoList_VuoGenericType1) data
)
{
	*data = VuoListCreate_VuoGenericType1();
	if (!message || !message->dataCount)
		return;

	*address = message->address;

	for (int i = 0; i < message->dataCount; ++i)
		VuoListAppendValue_VuoGenericType1(*data, VuoGenericType1_makeFromJson(message->data[i]));
}
